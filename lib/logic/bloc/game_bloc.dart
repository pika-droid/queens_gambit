import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../board_state.dart';
import '../n_queens_solver.dart';
import 'game_event.dart';
import 'game_state.dart';

export 'game_event.dart';
export 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  int _stateCounter = 0;
  bool _solverCancelled = false;
  int _totalBacktracks = 0;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final bool puzzleMode;

  GameBloc({this.puzzleMode = false}) : super(GameState.initial()) {
    on<GameStarted>(_onGameStarted);
    on<BoardSizeChanged>(_onBoardSizeChanged);
    on<SpeedChanged>(_onSpeedChanged);
    on<ToggleHeatmap>(_onToggleHeatmap);
    on<UserMove>(_onUserMove);
    on<SolveStarted>(_onSolveStarted);
    on<SolveCancelled>(_onSolveCancelled);
    on<ResetBoard>(_onResetBoard);
    on<GeneratePuzzle>(_onGeneratePuzzle);
    on<TimerTick>(_onTimerTick);
  }

  // ── helpers ──────────────────────────────────────────────────────────

  GameState _next(BoardState bs) {
    _stateCounter++;
    return GameState(boardState: bs, stateId: _stateCounter);
  }

  void _startTimer() {
    _stopwatch.reset();
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTick(_stopwatch.elapsed));
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
  }

  void _pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTick(_stopwatch.elapsed));
    });
  }

  // ── event handlers ──────────────────────────────────────────────────

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    final bs = state.boardState.copyWith(status: GameStatus.playing);
    _startTimer();
    emit(_next(bs));
  }

  void _onBoardSizeChanged(BoardSizeChanged event, Emitter<GameState> emit) {
    _stopTimer();
    final newBoard = BoardState.initial(n: event.n);
    emit(
      _next(
        newBoard.copyWith(
          animationDelay: state.boardState.animationDelay,
          showHeatmap: state.boardState.showHeatmap,
          status: GameStatus.playing,
        ),
      ),
    );
    _startTimer();

    // If we're in puzzle mode, regenerating the locked queens is required on resize
    if (puzzleMode) {
      add(const GeneratePuzzle());
    }
  }

  void _onSpeedChanged(SpeedChanged event, Emitter<GameState> emit) {
    emit(_next(state.boardState.copyWith(animationDelay: event.delayMs)));
  }

  void _onToggleHeatmap(ToggleHeatmap event, Emitter<GameState> emit) {
    emit(
      _next(
        state.boardState.copyWith(showHeatmap: !state.boardState.showHeatmap),
      ),
    );
  }

  void _onUserMove(UserMove event, Emitter<GameState> emit) {
    final bs = state.boardState;
    if (bs.status == GameStatus.solving) return; // locked during solve
    if (bs.lockedRows.contains(event.row)) return; // locked queen

    final newBoard = List<int>.from(bs.board);
    final currentCol = newBoard[event.row];

    int newMoves = bs.stats.movesMade;

    if (currentCol == event.col) {
      // Tap existing queen → remove it
      newBoard[event.row] = -1;
      newMoves++;
    } else {
      // Place or move queen to this column
      newBoard[event.row] = event.col;
      newMoves++;

      // Haptic feedback if the position is under attack
      if (!NQueensSolver.isSafe(newBoard, event.row, event.col)) {
        HapticFeedback.mediumImpact();
      }
    }

    final conflicts = NQueensSolver.findConflicts(newBoard);
    final placed = newBoard.where((c) => c != -1).length;

    GameStatus newStatus = bs.status == GameStatus.initial
        ? GameStatus.playing
        : bs.status;

    // Ensure timer is running
    if (!_stopwatch.isRunning) _startTimer();

    // Win check
    if (placed == bs.n && conflicts.isEmpty) {
      newStatus = GameStatus.solved;
      _stopTimer();
    }

    emit(
      _next(
        bs.copyWith(
          board: newBoard,
          conflictRows: conflicts,
          status: newStatus,
          stats: bs.stats.copyWith(movesMade: newMoves),
        ),
      ),
    );
  }

  // ── AI Solver (async visual) ────────────────────────────────────────

  Future<void> _onSolveStarted(
    SolveStarted event,
    Emitter<GameState> emit,
  ) async {
    _solverCancelled = false;
    _totalBacktracks = 0;
    _pauseTimer(); // Stop timer ticks to prevent concurrent state mutations
    final bs = state.boardState;

    emit(
      _next(
        bs.copyWith(
          status: GameStatus.solving,
          stats: bs.stats.copyWith(backtracks: 0),
        ),
      ),
    );

    // Run solver — emit directly from this handler (no add() queueing)
    final board = List<int>.from(bs.board);
    final lockedRows = bs.lockedRows;
    final n = bs.n;

    final solved = await _solveVisual(board, 0, n, lockedRows, emit);

    // Emit final state
    if (solved) {
      emit(
        _next(
          state.boardState.copyWith(
            board: List<int>.from(board),
            status: GameStatus.solved,
            conflictRows: {},
          ),
        ),
      );
      _stopTimer();
    } else if (!_solverCancelled) {
      emit(
        _next(
          state.boardState.copyWith(
            status: GameStatus.noSolution,
            conflictRows: NQueensSolver.findConflicts(state.boardState.board),
          ),
        ),
      );
      _resumeTimer();
    }
  }

  Future<bool> _solveVisual(
    List<int> board,
    int row,
    int n,
    Set<int> lockedRows,
    Emitter<GameState> emit,
  ) async {
    if (_solverCancelled) return false;
    if (row == n) return true;

    if (lockedRows.contains(row)) {
      return _solveVisual(board, row + 1, n, lockedRows, emit);
    }

    for (int col = 0; col < n; col++) {
      if (_solverCancelled) return false;

      if (NQueensSolver.isSafe(board, row, col)) {
        board[row] = col;

        // Emit step directly — no event queueing
        emit(
          _next(
            state.boardState.copyWith(
              board: List<int>.from(board),
              conflictRows: NQueensSolver.findConflicts(board),
              stats: state.boardState.stats.copyWith(
                backtracks: _totalBacktracks,
              ),
            ),
          ),
        );
        await Future.delayed(
          Duration(milliseconds: state.boardState.animationDelay),
        );

        if (await _solveVisual(board, row + 1, n, lockedRows, emit)) {
          return true;
        }

        board[row] = -1;
        _totalBacktracks++;

        emit(
          _next(
            state.boardState.copyWith(
              board: List<int>.from(board),
              conflictRows: NQueensSolver.findConflicts(board),
              stats: state.boardState.stats.copyWith(
                backtracks: _totalBacktracks,
              ),
            ),
          ),
        );
        await Future.delayed(
          Duration(milliseconds: state.boardState.animationDelay),
        );
      }
    }
    return false;
  }

  void _onSolveCancelled(SolveCancelled event, Emitter<GameState> emit) {
    _solverCancelled = true;
    emit(_next(state.boardState.copyWith(status: GameStatus.playing)));
    _resumeTimer();
  }

  void _onResetBoard(ResetBoard event, Emitter<GameState> emit) {
    _stopTimer();
    _solverCancelled = true;
    final bs = state.boardState;

    // Keep locked queens, clear the rest
    final newBoard = List<int>.filled(bs.n, -1);
    for (final row in bs.lockedRows) {
      newBoard[row] = bs.board[row];
    }

    emit(
      _next(
        bs.copyWith(
          board: newBoard,
          conflictRows: {},
          status: GameStatus.playing,
          stats: const GameStats(),
        ),
      ),
    );
    _startTimer();
  }

  void _onGeneratePuzzle(GeneratePuzzle event, Emitter<GameState> emit) {
    _stopTimer();
    _solverCancelled = true;
    final bs = state.boardState;
    final n = bs.n;
    final rng = Random();

    // Try to generate a valid partial board with 1-2 pre-placed queens.
    for (int attempt = 0; attempt < 100; attempt++) {
      final board = List<int>.filled(n, -1);
      final locked = <int>{};

      // Place first queen
      final r1 = rng.nextInt(n);
      final c1 = rng.nextInt(n);
      board[r1] = c1;
      locked.add(r1);

      // For n >= 5, place a second queen
      if (n >= 5) {
        for (int t = 0; t < 50; t++) {
          final r2 = rng.nextInt(n);
          final c2 = rng.nextInt(n);
          if (r2 == r1) continue;
          if (NQueensSolver.isSafe(board, r2, c2)) {
            board[r2] = c2;
            locked.add(r2);
            break;
          }
        }
      }

      // Verify solvability
      if (NQueensSolver.solveInstant(List.from(board), lockedRows: locked) !=
          null) {
        emit(
          _next(
            bs.copyWith(
              board: board,
              lockedRows: locked,
              conflictRows: {},
              status: GameStatus.playing,
              stats: const GameStats(),
            ),
          ),
        );
        _startTimer();
        return;
      }
    }

    // Fallback: empty board
    emit(
      _next(
        BoardState.initial(n: n).copyWith(
          status: GameStatus.playing,
          animationDelay: bs.animationDelay,
          showHeatmap: bs.showHeatmap,
        ),
      ),
    );
    _startTimer();
  }

  void _onTimerTick(TimerTick event, Emitter<GameState> emit) {
    emit(
      _next(
        state.boardState.copyWith(
          stats: state.boardState.stats.copyWith(elapsed: event.elapsed),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
