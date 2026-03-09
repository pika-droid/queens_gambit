import 'package:flutter_test/flutter_test.dart';
import 'package:queens_gambit/logic/n_queens_solver.dart';

void main() {
  group('NQueensSolver', () {
    group('isSafe', () {
      test('Empty board of size 4: placing queen at (0,0) is safe -> true', () {
        final board = [-1, -1, -1, -1];
        expect(NQueensSolver.isSafe(board, 0, 0), isTrue);
      });

      test('Queen at (0,0): placing at (1,0) (same column) -> false', () {
        final board = [0, -1, -1, -1];
        expect(NQueensSolver.isSafe(board, 1, 0), isFalse);
      });

      test('Queen at (0,0): placing at (1,1) (diagonal) -> false', () {
        final board = [0, -1, -1, -1];
        expect(NQueensSolver.isSafe(board, 1, 1), isFalse);
      });

      test(
        'Queen at (0,0): placing at (1,2) (L-shape, not diagonal) -> true',
        () {
          final board = [0, -1, -1, -1];
          expect(NQueensSolver.isSafe(board, 1, 2), isTrue);
        },
      );
    });

    group('findConflicts', () {
      test('Empty board -> empty set', () {
        final board = [-1, -1, -1, -1];
        expect(NQueensSolver.findConflicts(board), isEmpty);
      });

      test('Board with 2 queens sharing a column -> {0,1}', () {
        final board = [
          0,
          0,
          -1,
          -1,
        ]; // Row 0 and Row 1 both have queen at col 0
        expect(NQueensSolver.findConflicts(board), equals({0, 1}));
      });

      test('Valid partial board -> empty set', () {
        final board = [1, 3, -1, -1]; // Queens at (0,1) and (1,3)
        expect(NQueensSolver.findConflicts(board), isEmpty);
      });

      test('Diagonal conflict: queen at (0,0) and (1,1) -> {0,1}', () {
        final board = [0, 1, -1, -1];
        expect(NQueensSolver.findConflicts(board), equals({0, 1}));
      });
    });

    group('solveInstant', () {
      test('4x4 empty board -> not null (solution exists)', () {
        final board = [-1, -1, -1, -1];
        final solution = NQueensSolver.solveInstant(board, lockedRows: {});
        expect(solution, isNotNull);
        expect(NQueensSolver.findConflicts(solution!), isEmpty);
      });

      test('4x4 board with queen at (0,1) locked -> not null', () {
        final board = [1, -1, -1, -1];
        final solution = NQueensSolver.solveInstant(board, lockedRows: {0});
        expect(solution, isNotNull);
        expect(solution![0], equals(1)); // Locked queen remains
        expect(solution.where((x) => x != -1).length, equals(4)); // Solved
        expect(NQueensSolver.findConflicts(solution), isEmpty);
      });

      test('2x2 board -> null (no solution for n=2)', () {
        final board = [-1, -1];
        final solution = NQueensSolver.solveInstant(board, lockedRows: {});
        expect(solution, isNull);
      });

      test('3x3 board -> null (no solution for n=3)', () {
        final board = [-1, -1, -1];
        final solution = NQueensSolver.solveInstant(board, lockedRows: {});
        expect(solution, isNull);
      });

      test(
        'Solved 4x4 board passed in with locked rows -> solution matches original',
        () {
          // Solution 1 for N=4: [1, 3, 0, 2]
          final board = [1, 3, 0, 2];
          final solution = NQueensSolver.solveInstant(
            board,
            lockedRows: {0, 1, 2, 3},
          );
          expect(solution, equals(board));
        },
      );
    });
  });
}
