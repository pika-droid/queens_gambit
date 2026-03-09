import 'package:flutter_test/flutter_test.dart';
import 'package:queens_gambit/logic/board_state.dart';

void main() {
  group('BoardState', () {
    group('BoardState.initial', () {
      test(
        'n=4: board length is 4, all values -1, status is GameStatus.initial',
        () {
          final state = BoardState.initial(n: 4);
          expect(state.n, equals(4));
          expect(state.board.length, equals(4));
          expect(state.board.every((col) => col == -1), isTrue);
          expect(state.status, equals(GameStatus.initial));
          expect(state.lockedRows, isEmpty);
          expect(state.conflictRows, isEmpty);
        },
      );
    });

    group('placedQueens', () {
      test('Empty board -> 0', () {
        final state = BoardState.initial(n: 4);
        expect(state.placedQueens, equals(0));
      });

      test('Board with 2 queens placed -> 2', () {
        final state = BoardState(
          n: 4,
          board: [1, -1, 3, -1], // Queens at (0,1) and (2,3)
          status: GameStatus.playing,
        );
        expect(state.placedQueens, equals(2));
      });
    });

    group('isSolved', () {
      test('Full valid 4-queen solution with conflictRows empty -> true', () {
        final state = BoardState(
          n: 4,
          board: [1, 3, 0, 2],
          status: GameStatus.playing,
          conflictRows: const {},
        );
        expect(state.isSolved, isTrue);
      });

      test('Full board but conflictRows not empty -> false', () {
        final state = BoardState(
          n: 4,
          board: [0, 0, 0, 0], // Collisions everywhere
          status: GameStatus.playing,
          conflictRows: const {0, 1, 2, 3},
        );
        expect(state.isSolved, isFalse);
      });

      test('Partial board -> false', () {
        final state = BoardState(
          n: 4,
          board: [1, 3, -1, -1],
          status: GameStatus.playing,
          conflictRows: const {},
        );
        expect(state.isSolved, isFalse);
      });
    });

    group('computeHeatmap', () {
      test(
        'Queen at (0,0) in 4x4: row 0, column 0, and diagonals are false; (1,2) should be true',
        () {
          final state = BoardState(
            n: 4,
            board: [0, -1, -1, -1],
            status: GameStatus.playing,
          );
          final heatmap = state.computeHeatmap();

          expect(heatmap.length, equals(4));
          expect(heatmap[0].length, equals(4));

          // Row 0 is false
          expect(heatmap[0].every((safe) => !safe), isTrue);
          // Col 0 is false
          expect(heatmap[1][0], isFalse);
          expect(heatmap[2][0], isFalse);
          expect(heatmap[3][0], isFalse);
          // Diagonal
          expect(heatmap[1][1], isFalse);
          expect(heatmap[2][2], isFalse);
          expect(heatmap[3][3], isFalse);

          // (1,2) is safe
          expect(heatmap[1][2], isTrue);
        },
      );
    });

    group('safeSquaresRemaining', () {
      test('Empty board of n=4: all 16 squares are safe -> 16', () {
        final state = BoardState.initial(n: 4);
        expect(state.safeSquaresRemaining, equals(16));
      });

      test('Queen at corner (0,0): some squares become unsafe; count < 16', () {
        final state = BoardState(
          n: 4,
          board: [0, -1, -1, -1],
          status: GameStatus.playing,
        );
        // Safe: (1,2), (1,3), (2,1), (2,3), (3,1), (3,2) -> 6 squares
        expect(state.safeSquaresRemaining, equals(6));
      });
    });

    group('copyWith', () {
      test('Changing only showHeatmap leaves all other fields unchanged', () {
        final initial = BoardState.initial(n: 4);
        final updated = initial.copyWith(showHeatmap: true);

        expect(updated.showHeatmap, isTrue);
        expect(updated.n, equals(initial.n));
        expect(updated.board, equals(initial.board));
        expect(updated.status, equals(initial.status));
      });

      test('Providing new board updates the board field', () {
        final initial = BoardState.initial(n: 4);
        final newBoard = [1, -1, -1, -1];
        final updated = initial.copyWith(board: newBoard);

        expect(updated.board, equals(newBoard));
      });
    });

    group('GameStats copyWith', () {
      test('copyWith(backtracks: 5) updates only backtracks', () {
        const stats = GameStats(
          movesMade: 1,
          elapsed: Duration(seconds: 1),
          backtracks: 0,
        );
        final updated = stats.copyWith(backtracks: 5);

        expect(updated.backtracks, equals(5));
        expect(updated.movesMade, equals(stats.movesMade));
        expect(updated.elapsed, equals(stats.elapsed));
      });
    });
  });
}
