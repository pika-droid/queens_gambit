import 'package:equatable/equatable.dart';

/// Represents the current status of the game.
enum GameStatus { initial, playing, solving, solved, noSolution }

/// Statistics tracking for the game.
class GameStats extends Equatable {
  final int backtracks;
  final int movesMade;
  final Duration elapsed;

  const GameStats({
    this.backtracks = 0,
    this.movesMade = 0,
    this.elapsed = Duration.zero,
  });

  GameStats copyWith({int? backtracks, int? movesMade, Duration? elapsed}) {
    return GameStats(
      backtracks: backtracks ?? this.backtracks,
      movesMade: movesMade ?? this.movesMade,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  @override
  List<Object?> get props => [backtracks, movesMade, elapsed];
}

/// The complete board state for the N-Queens game.
class BoardState extends Equatable {
  /// Board size (4–10).
  final int n;

  /// 1D array: index = row, value = column of the queen (-1 = empty).
  final List<int> board;

  /// Rows whose queens are locked (Puzzle Mode).
  final Set<int> lockedRows;

  /// Whether the attack-zone heatmap is visible.
  final bool showHeatmap;

  /// Delay in ms for the AI solver animation.
  final int animationDelay;

  /// Current game status.
  final GameStatus status;

  /// Statistics.
  final GameStats stats;

  /// Rows that are currently in conflict (for UI highlighting).
  final Set<int> conflictRows;

  BoardState({
    required this.n,
    required this.board,
    this.lockedRows = const {},
    this.showHeatmap = false,
    this.animationDelay = 200,
    this.status = GameStatus.initial,
    this.stats = const GameStats(),
    this.conflictRows = const {},
  });

  /// Factory for the default initial state.
  factory BoardState.initial({int n = 4}) {
    return BoardState(n: n, board: List<int>.filled(n, -1));
  }

  /// The number of queens currently placed on the board.
  int get placedQueens => board.where((col) => col != -1).length;

  /// Whether the board is fully and validly solved.
  bool get isSolved => placedQueens == n && conflictRows.isEmpty;

  /// Count of safe squares remaining on the board.
  late final int safeSquaresRemaining = _computeSafeSquares();

  int _computeSafeSquares() {
    final heatmap = computeHeatmap();
    int count = 0;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (heatmap[r][c]) count++;
      }
    }
    return count;
  }

  /// Compute an N×N heatmap. `true` = safe, `false` = under attack.
  List<List<bool>> computeHeatmap() {
    final grid = List.generate(n, (_) => List.filled(n, true));

    for (int row = 0; row < n; row++) {
      final col = board[row];
      if (col == -1) continue;

      for (int i = 0; i < n; i++) {
        grid[row][i] = false; // entire row
        grid[i][col] = false; // entire column
        // diagonals
        final d1r = row + i, d1c = col + i;
        final d2r = row - i, d2c = col - i;
        final d3r = row + i, d3c = col - i;
        final d4r = row - i, d4c = col + i;
        if (d1r < n && d1c < n) grid[d1r][d1c] = false;
        if (d2r >= 0 && d2c >= 0) grid[d2r][d2c] = false;
        if (d3r < n && d3c >= 0) grid[d3r][d3c] = false;
        if (d4r >= 0 && d4c < n) grid[d4r][d4c] = false;
      }
    }
    return grid;
  }

  BoardState copyWith({
    int? n,
    List<int>? board,
    Set<int>? lockedRows,
    bool? showHeatmap,
    int? animationDelay,
    GameStatus? status,
    GameStats? stats,
    Set<int>? conflictRows,
  }) {
    return BoardState(
      n: n ?? this.n,
      board: board ?? this.board,
      lockedRows: lockedRows ?? this.lockedRows,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      animationDelay: animationDelay ?? this.animationDelay,
      status: status ?? this.status,
      stats: stats ?? this.stats,
      conflictRows: conflictRows ?? this.conflictRows,
    );
  }

  @override
  List<Object?> get props => [
    n,
    board,
    lockedRows,
    showHeatmap,
    animationDelay,
    status,
    stats,
    conflictRows,
  ];
}
