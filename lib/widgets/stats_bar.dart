import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../logic/bloc/game_bloc.dart';
import '../logic/board_state.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Queen Progress Strip ──
          BlocBuilder<GameBloc, GameState>(
            buildWhen: (prev, curr) =>
                prev.boardState.board != curr.boardState.board ||
                prev.boardState.n != curr.boardState.n,
            builder: (context, state) {
              final bs = state.boardState;
              final placed = bs.placedQueens;
              final total = bs.n;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.surfaceBorder.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Queens',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(total, (i) {
                          final isFilled = i < placed;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? AppTheme.gold.withValues(alpha: 0.2)
                                    : AppTheme.background.withValues(
                                        alpha: 0.4,
                                      ),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isFilled
                                      ? AppTheme.gold.withValues(alpha: 0.4)
                                      : AppTheme.surfaceBorder.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isFilled ? 1.0 : 0.15,
                                  child: Text(
                                    '♛',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isFilled
                                          ? AppTheme.gold
                                          : AppTheme.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$placed/$total',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: placed == total
                            ? AppTheme.success
                            : AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // ── Stat chips ──
          Row(
            children: [
              // Timer
              Expanded(
                child: BlocBuilder<GameBloc, GameState>(
                  buildWhen: (prev, curr) =>
                      prev.boardState.stats.elapsed !=
                      curr.boardState.stats.elapsed,
                  builder: (context, state) {
                    final elapsed = state.boardState.stats.elapsed;
                    final minutes = elapsed.inMinutes
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = elapsed.inSeconds
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    return _StatChip(
                      icon: Icons.timer_outlined,
                      label: '$minutes:$seconds',
                      color: AppTheme.textPrimary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Safe Squares
              Expanded(
                child: BlocBuilder<GameBloc, GameState>(
                  buildWhen: (prev, curr) =>
                      prev.boardState.board != curr.boardState.board ||
                      prev.boardState.n != curr.boardState.n,
                  builder: (context, state) {
                    return _StatChip(
                      icon: Icons.shield_outlined,
                      label: '${state.boardState.safeSquaresRemaining}',
                      sublabel: 'Safe',
                      color: AppTheme.success,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Moves
              Expanded(
                child: BlocBuilder<GameBloc, GameState>(
                  buildWhen: (prev, curr) =>
                      prev.boardState.stats.movesMade !=
                      curr.boardState.stats.movesMade,
                  builder: (context, state) {
                    return _StatChip(
                      icon: Icons.touch_app_outlined,
                      label: '${state.boardState.stats.movesMade}',
                      sublabel: 'Moves',
                      color: AppTheme.gold,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Backtracks (conditionally shown)
              BlocBuilder<GameBloc, GameState>(
                buildWhen: (prev, curr) =>
                    prev.boardState.stats.backtracks !=
                        curr.boardState.stats.backtracks ||
                    prev.boardState.status != curr.boardState.status,
                builder: (context, state) {
                  final bs = state.boardState;
                  if (bs.status != GameStatus.solving &&
                      bs.stats.backtracks == 0) {
                    return const SizedBox.shrink();
                  }
                  return Expanded(
                    child: _StatChip(
                      icon: Icons.undo,
                      label: '${bs.stats.backtracks}',
                      sublabel: 'Back',
                      color: AppTheme.danger,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
