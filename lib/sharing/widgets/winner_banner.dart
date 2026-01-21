import 'package:flutter/material.dart';

import '../constants/winner_messages.dart';

/// Banner displaying the winner of a score comparison.
class WinnerBanner extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final iWin = myTotal > friendTotal;
    final isTie = myTotal == friendTotal;
    final diff = (myTotal - friendTotal).abs();

    final message = WinnerMessages.getMessage(
      iWin: iWin,
      isTie: isTie,
      scoreDifference: diff,
    );

    final gradientColors = isTie
        ? [Colors.grey.shade600, Colors.grey.shade700]
        : iWin
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
          // Trophy/handshake icon
          Icon(
            isTie ? Icons.handshake : Icons.emoji_events,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          // Winner text
          Text(
            _getWinnerText(iWin, isTie),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Score difference
          if (!isTie)
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

  String _getWinnerText(bool iWin, bool isTie) {
    if (isTie) {
      return "IT'S A TIE!";
    }
    if (iWin) {
      return 'YOU WIN!';
    }
    return '$friendName WINS!';
  }
}
