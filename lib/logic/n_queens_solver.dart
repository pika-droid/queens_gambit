/// Pure logic utilities for the N-Queens problem.
class NQueensSolver {
  /// Check whether placing a queen at [row],[col] is safe given [board].
  /// [board] is a 1D list where index = row, value = col (-1 = empty).
  static bool isSafe(List<int> board, int row, int col) {
    for (int i = 0; i < board.length; i++) {
      if (i == row) continue;
      final qCol = board[i];
      if (qCol == -1) continue;

      // Same column
      if (qCol == col) return false;

      // Diagonal
      if ((qCol - col).abs() == (i - row).abs()) return false;
    }
    return true;
  }

  /// Find all rows that are in conflict on the given [board].
  static Set<int> findConflicts(List<int> board) {
    final conflicts = <int>{};
    for (int i = 0; i < board.length; i++) {
      if (board[i] == -1) continue;
      for (int j = i + 1; j < board.length; j++) {
        if (board[j] == -1) continue;
        if (board[i] == board[j] ||
            (board[i] - board[j]).abs() == (i - j).abs()) {
          conflicts.add(i);
          conflicts.add(j);
        }
      }
    }
    return conflicts;
  }

  /// Instantly solve the N-Queens problem starting from a partial [board].
  /// [lockedRows] are rows whose queens must not be moved.
  /// Returns the solved board list, or `null` if no solution exists.
  static List<int>? solveInstant(
    List<int> board, {
    Set<int> lockedRows = const {},
  }) {
    final result = List<int>.from(board);
    if (_backtrack(result, 0, lockedRows)) {
      return result;
    }
    return null;
  }

  static bool _backtrack(List<int> board, int row, Set<int> lockedRows) {
    final n = board.length;
    if (row == n) return true;

    // If this row is locked, skip it (queen already placed).
    if (lockedRows.contains(row)) {
      return _backtrack(board, row + 1, lockedRows);
    }

    for (int col = 0; col < n; col++) {
      if (isSafe(board, row, col)) {
        board[row] = col;
        if (_backtrack(board, row + 1, lockedRows)) return true;
        board[row] = -1;
      }
    }
    return false;
  }
}
