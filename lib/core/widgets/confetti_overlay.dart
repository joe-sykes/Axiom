import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
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
              child: Lottie.asset(
                'assets/confetti_success.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward();
                },
                fit: BoxFit.cover,
                frameRate: const FrameRate(60),
                renderCache: RenderCache.raster,
              ),
            ),
          ),
      ],
    );
  }
}

/// A simpler version that can be shown in a dialog or overlay
class ConfettiAnimation extends StatelessWidget {
  final VoidCallback? onComplete;

  const ConfettiAnimation({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Lottie.asset(
        'assets/confetti_success.json',
        repeat: false,
        fit: BoxFit.cover,
        frameRate: const FrameRate(60),
        renderCache: RenderCache.raster,
        onLoaded: (composition) {
          if (onComplete != null) {
            Future.delayed(composition.duration, onComplete);
          }
        },
      ),
    );
  }
}
