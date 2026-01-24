import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/winner_messages.dart';

/// Banner displaying the winner of a score comparison.
class WinnerBanner extends StatefulWidget {
  final int myTotal;
  final int friendTotal;
  final String myName;
  final String friendName;

  const WinnerBanner({
    super.key,
    required this.myTotal,
    required this.friendTotal,
    required this.myName,
    required this.friendName,
  });

  @override
  State<WinnerBanner> createState() => _WinnerBannerState();
}

class _WinnerBannerState extends State<WinnerBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _loopCount = 0;
  static const int _maxLoops = 3;

  bool get _iWin => widget.myTotal > widget.friendTotal;
  bool get _isTie => widget.myTotal == widget.friendTotal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loopCount++;
        if (_loopCount < _maxLoops) {
          _controller.forward(from: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = (widget.myTotal - widget.friendTotal).abs();

    final message = WinnerMessages.getMessage(
      iWin: _iWin,
      isTie: _isTie,
      scoreDifference: diff,
    );

    final gradientColors = _isTie
        ? [Colors.grey.shade600, Colors.grey.shade700]
        : _iWin
            ? [Colors.green.shade600, Colors.teal.shade600]
            : [Colors.orange.shade600, Colors.deepOrange.shade600];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trophy animation (when winning) or handshake icon (tie/loss)
          if (_iWin)
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/Trophy_winner.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward();
                },
                fit: BoxFit.contain,
                frameRate: const FrameRate(60),
                renderCache: RenderCache.raster,
              ),
            )
          else
            Icon(
              _isTie ? Icons.handshake : Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.white,
            ),
          const SizedBox(height: 16),
          // Winner text
          Text(
            _getWinnerText(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Score difference
          if (!_isTie)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'by $diff points',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Fun message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getWinnerText() {
    if (_isTie) {
      return "IT'S A TIE!";
    }
    if (_iWin) {
      return 'YOU WIN!';
    }
    return '${widget.friendName} WINS!';
  }
}
