import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.show,
    this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _particles = _generateParticles();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  List<ConfettiParticle> _generateParticles() {
    const colors = [
      Color(0xFF4E98F8), // Blue
      Color(0xFFE55D5B), // Red
      Color(0xFFF6C567), // Yellow
      Color(0xFF92CD61), // Green
      Color(0xFFB27BE6), // Purple
    ];

    return List.generate(50, (index) {
      return ConfettiParticle(
        color: colors[_random.nextInt(colors.length)],
        startX: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.2,
        endX: _random.nextDouble() * 0.4 - 0.2 + (_random.nextDouble()),
        endY: 1.2 + _random.nextDouble() * 0.3,
        rotation: _random.nextDouble() * 4 * pi,
        size: 8 + _random.nextDouble() * 8,
        delay: _random.nextDouble() * 0.3,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _particles.clear();
      _particles.addAll(_generateParticles());
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.show)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;
  final double delay;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.size,
    required this.delay,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final x = size.width * (particle.startX + (particle.endX - particle.startX) * adjustedProgress);
      final y = size.height * (particle.startY + (particle.endY - particle.startY) * _easeOut(adjustedProgress));
      final rotation = particle.rotation * adjustedProgress;
      final opacity = adjustedProgress < 0.8 ? 1.0 : (1.0 - (adjustedProgress - 0.8) / 0.2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
        paint,
      );

      canvas.restore();
    }
  }

  double _easeOut(double t) {
    return 1 - pow(1 - t, 2).toDouble();
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

/// A simpler version that can be shown in a dialog or overlay
class ConfettiAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiAnimation({super.key, this.onComplete});

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _particles = _generateParticles();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    _controller.forward();
  }

  List<ConfettiParticle> _generateParticles() {
    const colors = [
      Color(0xFF4E98F8),
      Color(0xFFE55D5B),
      Color(0xFFF6C567),
      Color(0xFF92CD61),
      Color(0xFFB27BE6),
    ];

    return List.generate(50, (index) {
      return ConfettiParticle(
        color: colors[_random.nextInt(colors.length)],
        startX: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.2,
        endX: _random.nextDouble() * 0.4 - 0.2 + (_random.nextDouble()),
        endY: 1.2 + _random.nextDouble() * 0.3,
        rotation: _random.nextDouble() * 4 * pi,
        size: 8 + _random.nextDouble() * 8,
        delay: _random.nextDouble() * 0.3,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}
