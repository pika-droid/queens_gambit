import 'package:equatable/equatable.dart';
import '../board_state.dart';

/// Immutable BLoC state wrapping [BoardState].
///
/// We keep a thin wrapper so that BLoC-specific concerns (like a unique
/// `stateId` for forcing rebuilds during solver animation) stay separate
/// from the pure domain model.
class GameState extends Equatable {
  final BoardState boardState;

  /// Monotonically increasing ID so BlocBuilder always rebuilds during
  /// solver animation even when the board list reference hasn't changed.
  final int stateId;

  const GameState({required this.boardState, this.stateId = 0});

  factory GameState.initial({int n = 4}) {
    return GameState(boardState: BoardState.initial(n: n));
  }

  GameState copyWith({BoardState? boardState, int? stateId}) {
    return GameState(
      boardState: boardState ?? this.boardState,
      stateId: stateId ?? this.stateId,
    );
  }

  @override
  List<Object?> get props => [boardState, stateId];
}
