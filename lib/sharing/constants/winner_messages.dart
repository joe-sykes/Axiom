import 'dart:math';

/// Messages displayed when comparing scores with a friend.
class WinnerMessages {
  WinnerMessages._();

  static final _random = Random();

  /// Pick a random message from a list.
  static String _pick(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  /// Get an appropriate message based on the score difference.
  static String getMessage({
    required bool iWin,
    required bool isTie,
    required int scoreDifference,
  }) {
    if (isTie) {
      return _pick(tieMessages);
    }

    if (scoreDifference >= 50) {
      return iWin ? _pick(dominantWinMessages) : _pick(dominantLossMessages);
    }

    if (scoreDifference <= 20) {
      return iWin ? _pick(closeWinMessages) : _pick(closeLossMessages);
    }

    return iWin ? _pick(winMessages) : _pick(lossMessages);
  }

  /// Messages for close wins (within 20 points).
  static const closeWinMessages = [
    'That was close! Well played.',
    'A nail-biter! You edged them out.',
    'Photo finish! Victory is yours.',
    'Squeaked by! Every point counted.',
    'Down to the wire! Great finish.',
  ];

  /// Messages for close losses (within 20 points).
  static const closeLossMessages = [
    'So close! You almost had it.',
    'A heartbreaker by just a few points.',
    'Nearly there! Better luck tomorrow.',
    'Tight game! They just edged you out.',
    'Almost! A few more points next time.',
  ];

  /// Messages for dominant wins (50+ points).
  static const dominantWinMessages = [
    'Total domination! Were they even trying?',
    'Absolute masterclass performance!',
    'You crushed it! Time for a new challenger.',
    'They never stood a chance!',
    'Flawless victory! Take a bow.',
  ];

  /// Messages for dominant losses (50+ points).
  static const dominantLossMessages = [
    'Ouch! That was rough.',
    'They really brought their A-game today.',
    "Well, there's always tomorrow...",
    'Time to practice! They schooled you.',
    'A humbling experience. Rise again!',
  ];

  /// Messages for regular wins.
  static const winMessages = [
    "Solid win! You've got the skills.",
    'Victory! Your puzzling prowess shines.',
    'Well done! Champion material.',
    'Winner winner! Share the glory.',
    'Nice work! The leaderboard awaits.',
  ];

  /// Messages for regular losses.
  static const lossMessages = [
    'Good effort! They were just better today.',
    'Tough break. Challenge them again!',
    'Lost the battle, not the war.',
    'Study up and come back stronger!',
    'A worthy opponent. Next time!',
  ];

  /// Messages for ties.
  static const tieMessages = [
    'Great minds think alike!',
    'A perfect match! Try again tomorrow.',
    'Evenly matched puzzle masters!',
    'Dead heat! Time for a rematch.',
    'Identical scores! What are the odds?',
  ];
}
