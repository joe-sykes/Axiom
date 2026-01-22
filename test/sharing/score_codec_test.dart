import 'package:flutter_test/flutter_test.dart';
import 'package:axiom/sharing/services/score_codec.dart';
import 'package:axiom/sharing/models/daily_scores.dart';
import 'package:axiom/sharing/models/user_profile.dart';
import 'package:axiom/sharing/constants/emoji_lists.dart';
import 'package:axiom/sharing/providers/sharing_providers.dart';

void main() {
  test('Debug friend URL decode', () {
    const url = 'https://axiompuzzles.web.app/c/C8Fo9FCsG4wzTEA';

    print('=== URL DECODE DEBUG ===');
    print('Input URL: $url');

    // Use the same logic as decodeShareData
    final result = decodeShareData(url);

    print('');
    print('=== RESULT ===');
    print('Valid: ${result.isValid}');
    print('Error: ${result.errorMessage}');
    print('Player: ${result.playerName}');
    print('Emoji index: ${result.emojiIndex}');
    print('Date: ${result.date}');
    print('Scores: ${result.scores}');
    print('Total: ${result.totalScore}');

    // Also try direct decode
    const data = 'C8Fo9FCsG4wzTEA';
    print('');
    print('=== DIRECT DECODE ===');
    final direct = ScoreCodec.decode(data);
    print('Valid: ${direct.isValid}');
    print('Error: ${direct.errorMessage}');
    print('Scores: ${direct.scores}');
  });

  test('Debug emoji encoding/decoding', () {
    final scores = DailyScores(
      date: DateTime.now().toUtc(),
      scores: {
        GameType.almanac: 85,
        GameType.cryptix: 70,
        GameType.cryptogram: 90,
        GameType.doublet: 65,
        GameType.triverse: 80,
      },
    );

    final profile = UserProfile(name: 'JANE', emojiIndex: 42);

    final encoded = ScoreCodec.encode(scores, profile);
    final emojiString = ScoreCodec.toEmojiString(encoded, profile);

    print('');
    print('=== ORIGINAL ===');
    print('Base64: $encoded');
    print('Base64 length: ${encoded.length}');
    print('Emoji string: $emojiString');
    print('');

    // Parse the emoji string manually
    final spaceIndex = emojiString.indexOf(' ');
    final header = emojiString.substring(0, spaceIndex);
    final emojiPart = emojiString.substring(spaceIndex + 1);
    print('=== PARSED ===');
    print('Header: $header');
    print('Emoji part: $emojiPart');
    print('Emoji part runes: ${emojiPart.runes.length}');
    print('');

    // Test fromEmojiString
    final extractedBase64 = ScoreCodec.fromEmojiString(emojiString);
    print('=== EXTRACTION ===');
    print('Extracted: $extractedBase64');
    print('Original:  $encoded');
    print('Match: ${extractedBase64 == encoded}');
    print('');

    // Decode both and compare
    print('=== DECODE COMPARISON ===');
    final decodedOriginal = ScoreCodec.decode(encoded);
    print('Original decode - Valid: ${decodedOriginal.isValid}, Scores: ${decodedOriginal.scores}');

    if (extractedBase64 != null) {
      final decodedExtracted = ScoreCodec.decode(extractedBase64);
      print('Extracted decode - Valid: ${decodedExtracted.isValid}, Scores: ${decodedExtracted.scores}');
    }

    // Check emoji list
    print('');
    print('=== EMOJI LIST CHECK ===');
    print('Encoding emoji count: ${EmojiLists.encodingEmojis.length}');

    // Check each emoji in the emoji part
    final runes = emojiPart.runes.toList();
    print('Runes in emoji part: $runes');

    int i = 0;
    int emojiCount = 0;
    while (i < runes.length) {
      String emoji;
      int index = -1;

      // Try 2-rune emoji first
      if (i + 1 < runes.length) {
        emoji = String.fromCharCodes([runes[i], runes[i + 1]]);
        index = EmojiLists.getEncodingIndex(emoji);
        if (index != -1) {
          print('Emoji $emojiCount: "$emoji" (2 runes) -> index $index');
          i += 2;
          emojiCount++;
          continue;
        }
      }

      // Try single rune
      emoji = String.fromCharCode(runes[i]);
      index = EmojiLists.getEncodingIndex(emoji);
      print('Emoji $emojiCount: "$emoji" (1 rune, code ${runes[i]}) -> index $index');
      if (index != -1) {
        emojiCount++;
      }
      i++;
    }
    print('Total emojis found: $emojiCount');
  });
}
