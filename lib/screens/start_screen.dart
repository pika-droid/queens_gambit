import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // ── Entrance animation ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // ── Shimmer on crown icon ──
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmer = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // ── Float animation for background pieces ──
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _navigateToGame(BuildContext context, {bool puzzleMode = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(puzzleMode: puzzleMode),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Animated Background ──
          _FloatingQueens(controller: _floatController),

          // ── Radial gradient overlay ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Crown Icon with Shimmer ──
                          _ShimmerCrown(shimmer: _shimmer),
                          const SizedBox(height: 32),

                          // ── Title ──
                          Text(
                            "Queen's Gambit",
                            style: AppTheme.titleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'N-QUEENS VISUALIZER',
                            style: AppTheme.subtitleStyle,
                          ),
                          const SizedBox(height: 48),

                          // ── Decorative divider ──
                          _GoldDivider(),
                          const SizedBox(height: 48),

                          // ── Sandbox Button ──
                          _StartButton(
                            label: 'Sandbox',
                            subtitle: 'Place queens freely on the board',
                            icon: Icons.grid_on_rounded,
                            delay: 0,
                            entranceController: _entranceController,
                            onTap: () => _navigateToGame(context),
                          ),
                          const SizedBox(height: 14),

                          // ── Puzzle Mode Button ──
                          _StartButton(
                            label: 'Puzzle Mode',
                            subtitle: 'Solve a pre-set challenge',
                            icon: Icons.extension_rounded,
                            delay: 1,
                            entranceController: _entranceController,
                            onTap: () =>
                                _navigateToGame(context, puzzleMode: true),
                          ),
                          const SizedBox(height: 48),

                          // ── Footer ──
                          Text(
                            'Board sizes 4 – 10  ·  Backtracking AI',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating queen silhouettes in the background
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingQueens extends StatelessWidget {
  final AnimationController controller;

  const _FloatingQueens({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _FloatingQueensPainter(controller.value),
        );
      },
    );
  }
}

class _FloatingQueensPainter extends CustomPainter {
  final double progress;
  static final List<_FloatingPiece> _pieces = _generatePieces();

  _FloatingQueensPainter(this.progress);

  static List<_FloatingPiece> _generatePieces() {
    final rng = Random(42); // fixed seed for consistency
    return List.generate(8, (i) {
      return _FloatingPiece(
        baseX: rng.nextDouble(),
        baseY: rng.nextDouble(),
        size: 18 + rng.nextDouble() * 22,
        speed: 0.3 + rng.nextDouble() * 0.7,
        phase: rng.nextDouble() * 2 * pi,
        opacity: 0.03 + rng.nextDouble() * 0.05,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _pieces) {
      final t = progress * piece.speed + piece.phase;
      final x = piece.baseX * size.width + sin(t * 2 * pi) * 30;
      final y = piece.baseY * size.height + cos(t * 2 * pi * 0.7) * 20;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '♛',
          style: TextStyle(
            fontSize: piece.size,
            color: AppTheme.gold.withValues(alpha: piece.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(_FloatingQueensPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FloatingPiece {
  final double baseX, baseY, size, speed, phase, opacity;
  const _FloatingPiece({
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Crown Icon
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerCrown extends StatelessWidget {
  final Animation<double> shimmer;

  const _ShimmerCrown({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.4 + shimmer.value * 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(
                  alpha: 0.08 + shimmer.value * 0.12,
                ),
                blurRadius: 30 + shimmer.value * 10,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [AppTheme.gold, AppTheme.goldLight, AppTheme.gold],
                  stops: [
                    (shimmer.value - 0.3).clamp(0.0, 1.0),
                    shimmer.value.clamp(0.0, 1.0),
                    (shimmer.value + 0.3).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold Divider
// ─────────────────────────────────────────────────────────────────────────────

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.gold.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.diamond_outlined,
            size: 14,
            color: AppTheme.gold.withValues(alpha: 0.4),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.gold.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start Screen Button with hover, press, and staggered entrance
// ─────────────────────────────────────────────────────────────────────────────

class _StartButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int delay;
  final AnimationController entranceController;

  const _StartButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.delay,
    required this.entranceController,
  });

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _hovering = false;
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    // Staggered entrance with delay
    final staggeredFade = CurvedAnimation(
      parent: widget.entranceController,
      curve: Interval(
        0.3 + widget.delay * 0.15,
        0.8 + widget.delay * 0.1,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: staggeredFade,
      child: MouseRegion(
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
            scale: _pressing ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: _hovering ? AppTheme.surfaceLight : AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hovering
                      ? AppTheme.gold.withValues(alpha: 0.4)
                      : AppTheme.surfaceBorder.withValues(alpha: 0.5),
                  width: _hovering ? 1.5 : 1,
                ),
                boxShadow: [
                  if (_hovering)
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon with glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(
                        alpha: _hovering ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: AppTheme.gold, size: 24),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label, style: AppTheme.buttonLabelStyle),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSlide(
                    offset: Offset(_hovering ? 0.15 : 0, 0),
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _hovering
                          ? AppTheme.gold.withValues(alpha: 0.6)
                          : AppTheme.textTertiary,
                      size: 16,
                    ),
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
