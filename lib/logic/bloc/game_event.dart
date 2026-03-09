import 'package:equatable/equatable.dart';

/// Base class for all game events.
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// User changed the board size via slider.
class BoardSizeChanged extends GameEvent {
  final int n;
  const BoardSizeChanged(this.n);

  @override
  List<Object?> get props => [n];
}

/// User changed the solver animation speed.
class SpeedChanged extends GameEvent {
  final int delayMs;
  const SpeedChanged(this.delayMs);

  @override
  List<Object?> get props => [delayMs];
}

/// Toggle the attack-zone heatmap overlay.
class ToggleHeatmap extends GameEvent {
  const ToggleHeatmap();
}

/// User tapped a square to place or remove a queen.
class UserMove extends GameEvent {
  final int row;
  final int col;
  const UserMove(this.row, this.col);

  @override
  List<Object?> get props => [row, col];
}

/// Start the AI solver visualisation.
class SolveStarted extends GameEvent {
  const SolveStarted();
}

/// Cancel the AI solver mid-run.
class SolveCancelled extends GameEvent {
  const SolveCancelled();
}

/// Reset the board (clear all queens).
class ResetBoard extends GameEvent {
  const ResetBoard();
}

/// Generate a new puzzle with pre-placed locked queens.
class GeneratePuzzle extends GameEvent {
  const GeneratePuzzle();
}

/// Tick the game timer.
class TimerTick extends GameEvent {
  final Duration elapsed;
  const TimerTick(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

/// Start the game (transition from initial → playing).
class GameStarted extends GameEvent {
  const GameStarted();
}
