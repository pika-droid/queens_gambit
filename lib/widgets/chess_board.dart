import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../logic/bloc/game_bloc.dart';
import '../logic/board_state.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (prev, curr) {
        final p = prev.boardState;
        final c = curr.boardState;
        return p.n != c.n ||
            p.status != c.status ||
            p.showHeatmap != c.showHeatmap ||
            !listEquals(p.board, c.board) ||
            !setEquals(p.conflictRows, c.conflictRows) ||
            !setEquals(p.lockedRows, c.lockedRows);
      },
      builder: (context, state) {
        final bs = state.boardState;
        final n = bs.n;
        final heatmap = bs.showHeatmap ? bs.computeHeatmap() : null;
        final isSolving = bs.status == GameStatus.solving;

        return AspectRatio(
          aspectRatio: 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Board with labels
                Expanded(
                  child: Row(
                    children: [
                      // Row labels (numbers)
                      SizedBox(
                        width: 20,
                        child: Column(
                          children: List.generate(n, (i) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  '${n - i}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Board
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.boardBorder,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: AppTheme.gold.withValues(alpha: 0.04),
                                blurRadius: 30,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: n,
                                ),
                            itemCount: n * n,
                            itemBuilder: (context, index) {
                              final row = index ~/ n;
                              final col = index % n;
                              final hasQueen = bs.board[row] == col;
                              final isLocked = bs.lockedRows.contains(row);
                              final hasConflict =
                                  bs.conflictRows.contains(row) && hasQueen;
                              final isUnsafe =
                                  heatmap != null && !heatmap[row][col];

                              return _SquareTile(
                                row: row,
                                col: col,
                                hasQueen: hasQueen,
                                isLocked: isLocked,
                                hasConflict: hasConflict,
                                isHeatmapUnsafe: isUnsafe,
                                isSolving: isSolving,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Column labels (letters)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: List.generate(n, (i) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            String.fromCharCode(97 + i), // a, b, c, ...
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SquareTile extends StatefulWidget {
  final int row;
  final int col;
  final bool hasQueen;
  final bool isLocked;
  final bool hasConflict;
  final bool isHeatmapUnsafe;
  final bool isSolving;

  const _SquareTile({
    required this.row,
    required this.col,
    required this.hasQueen,
    required this.isLocked,
    required this.hasConflict,
    required this.isHeatmapUnsafe,
    required this.isSolving,
  });

  @override
  State<_SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<_SquareTile> {
  bool _hovering = false;

  bool get _isDark => (widget.row + widget.col) % 2 == 1;

  @override
  Widget build(BuildContext context) {
    // Base colours
    final baseColor = _isDark ? AppTheme.boardDark : AppTheme.boardLight;

    // Layer overlays
    Color tileColor = baseColor;

    if (widget.isHeatmapUnsafe && !widget.hasQueen) {
      tileColor = Color.lerp(
        baseColor,
        const Color(0xFFB71C1C),
        _isDark ? 0.35 : 0.25,
      )!;
    }

    if (widget.hasConflict) {
      tileColor = Color.lerp(baseColor, Colors.red, 0.50)!;
    }

    // Hover highlight
    if (_hovering && !widget.isSolving) {
      tileColor = Color.lerp(tileColor, Colors.white, 0.08)!;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.isSolving
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isSolving
            ? null
            : () {
                context.read<GameBloc>().add(UserMove(widget.row, widget.col));
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: tileColor,
          child: widget.hasQueen
              ? _QueenIcon(
                  isLocked: widget.isLocked,
                  hasConflict: widget.hasConflict,
                )
              : null,
        ),
      ),
    );
  }
}

class _QueenIcon extends StatefulWidget {
  final bool isLocked;
  final bool hasConflict;

  const _QueenIcon({required this.isLocked, required this.hasConflict});

  @override
  State<_QueenIcon> createState() => _QueenIconState();
}

class _QueenIconState extends State<_QueenIcon> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLocked
        ? const Color(0xFF666666)
        : widget.hasConflict
        ? const Color(0xFFC62828)
        : const Color(0xFF1A1A1A);

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.7,
        child: FittedBox(
          child: AnimatedScale(
            scale: _visible ? 1.0 : 0.75,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Text(
              '♛',
              style: TextStyle(
                color: color,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(1, 2),
                  ),
                  if (!widget.isLocked && !widget.hasConflict)
                    Shadow(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
