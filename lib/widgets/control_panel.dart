import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../logic/bloc/game_bloc.dart';
import '../logic/board_state.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final bs = state.boardState;
        final isSolving = bs.status == GameStatus.solving;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: AppTheme.panelDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Row 1: Board Size ──
              _SliderRow(
                icon: Icons.grid_on_rounded,
                label: 'Board',
                valueLabel: '${bs.n}×${bs.n}',
                value: bs.n.toDouble(),
                min: 4,
                max: 10,
                divisions: 6,
                enabled: !isSolving,
                onChanged: (v) =>
                    context.read<GameBloc>().add(BoardSizeChanged(v.round())),
              ),
              const SizedBox(height: 6),

              // ── Row 2: Speed ──
              _SliderRow(
                icon: Icons.speed,
                label: 'Speed',
                valueLabel: '${bs.animationDelay}ms',
                value: bs.animationDelay.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                enabled: true,
                onChanged: (v) =>
                    context.read<GameBloc>().add(SpeedChanged(v.round())),
              ),
              const SizedBox(height: 12),

              // ── Row 3: Heatmap toggle ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.background.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      bs.showHeatmap
                          ? Icons.local_fire_department
                          : Icons.local_fire_department_outlined,
                      size: 18,
                      color: bs.showHeatmap
                          ? AppTheme.danger
                          : AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Attack Zones',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: bs.showHeatmap
                            ? AppTheme.textSecondary
                            : AppTheme.textTertiary,
                        fontWeight: bs.showHeatmap
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: bs.showHeatmap,
                      onChanged: (_) =>
                          context.read<GameBloc>().add(const ToggleHeatmap()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Row 4: Action buttons ──
              Row(
                children: [
                  // New Puzzle
                  Expanded(
                    child: _ActionButton(
                      label: 'Puzzle',
                      icon: Icons.extension_rounded,
                      enabled: !isSolving,
                      onTap: () async {
                        if (bs.placedQueens > 0) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.surface,
                              title: const Text(
                                'Start New Puzzle?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'This will clear your current board.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.gold,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'Start',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                        }
                        if (context.mounted) {
                          context.read<GameBloc>().add(const GeneratePuzzle());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Solve / Stop
                  Expanded(
                    flex: 2,
                    child: isSolving
                        ? _GradientActionButton(
                            label: 'Stop',
                            icon: Icons.stop_rounded,
                            gradient: AppTheme.dangerGradient,
                            onTap: () => context.read<GameBloc>().add(
                              const SolveCancelled(),
                            ),
                          )
                        : _GradientActionButton(
                            label: 'Solve',
                            icon: Icons.auto_fix_high,
                            gradient: AppTheme.goldGradient,
                            onTap: () => context.read<GameBloc>().add(
                              const SolveStarted(),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),

                  // Clear
                  Expanded(
                    child: _ActionButton(
                      label: 'Clear',
                      icon: Icons.clear_all_rounded,
                      enabled: !isSolving,
                      onTap: () =>
                          context.read<GameBloc>().add(const ResetBoard()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slider row
// ─────────────────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            valueLabel,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.gold,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outline action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enabled ? 1.0 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _hovering && widget.enabled
                  ? AppTheme.surfaceLight
                  : AppTheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovering && widget.enabled
                    ? AppTheme.textTertiary.withValues(alpha: 0.4)
                    : AppTheme.surfaceBorder.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 20, color: AppTheme.textSecondary),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient action button (Solve / Stop)
// ─────────────────────────────────────────────────────────────────────────────

class _GradientActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton> {
  bool _hovering = false;
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) {
          setState(() => _pressing = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressing = false),
        child: AnimatedScale(
          scale: _pressing ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: widget.gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: -4,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 22, color: AppTheme.background),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.background,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
