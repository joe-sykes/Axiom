import 'dart:convert';
import 'dart:typed_data';

import 'package:characters/characters.dart';

import '../constants/emoji_lists.dart';
import '../models/comparison_data.dart';
import '../models/daily_scores.dart';
import '../models/user_profile.dart';

/// Codec for encoding/decoding score sharing data.
///
/// Bit layout (83 bits for 5 games):
/// - Version: 2 bits (0-3)
/// - Date: 12 bits (days since Jan 1, 2024)
/// - Game count: 4 bits (1-12)
/// - Scores: 5 bits × n (score ÷ 5, clamped 0-20)
/// - Name: 20 bits (4 chars × 5 bits, A=0, Z=25)
/// - Emoji index: 8 bits (0-255)
/// - Checksum: 12 bits (CRC-12 with day salt)
class ScoreCodec {
  ScoreCodec._();

  /// Current protocol version.
  static const int _version = 0;

  /// Reference date for calculating day offset.
  static final DateTime _referenceDate = DateTime.utc(2024, 1, 1);

  /// Encode scores and profile to a base64 string.
  static String encode(DailyScores scores, UserProfile profile) {
    final buffer = _BitWriter();

    // Version (2 bits)
    buffer.write(_version, 2);

    // Date (12 bits) - days since reference
    final daysSinceRef = scores.date.toUtc().difference(_referenceDate).inDays;
    buffer.write(daysSinceRef.clamp(0, 4095), 12);

    // Game count (4 bits)
    final gameCount = scores.scores.length;
    buffer.write(gameCount.clamp(1, 12), 4);

    // Scores (5 bits each, value 0-20 representing 0-100 in steps of 5)
    for (final game in GameType.values) {
      final score = scores.scores[game] ?? 0;
      final encoded = (score / 5).round().clamp(0, 20);
      buffer.write(encoded, 5);
    }

    // Name (20 bits = 4 chars × 5 bits)
    for (int i = 0; i < 4; i++) {
      final char = i < profile.name.length ? profile.name.codeUnitAt(i) : 65;
      final value = (char - 65).clamp(0, 25); // A=0, Z=25
      buffer.write(value, 5);
    }

    // Emoji index (8 bits)
    buffer.write(profile.emojiIndex.clamp(0, 255), 8);

    // Get bytes without checksum for calculation
    final dataBytes = buffer.toBytes();

    // Calculate checksum (12 bits) with day salt
    final checksum = _calculateChecksum(dataBytes, daysSinceRef);
    buffer.write(checksum, 12);

    // Convert to base64
    return _toBase64(buffer.toBytes());
  }

  /// Decode a base64 string to comparison data.
  static ComparisonData decode(String encoded) {
    try {
      final bytes = _fromBase64(encoded);
      if (bytes.isEmpty) {
        return ComparisonData.invalid('Invalid encoding');
      }

      final reader = _BitReader(bytes);

      // Version (2 bits)
      final version = reader.read(2);
      if (version > _version) {
        return ComparisonData.invalid('Unsupported version');
      }

      // Date (12 bits)
      final daysSinceRef = reader.read(12);
      final date = _referenceDate.add(Duration(days: daysSinceRef));

      // Game count (4 bits)
      final gameCount = reader.read(4);
      if (gameCount < 1 || gameCount > 12) {
        return ComparisonData.invalid('Invalid game count');
      }

      // Scores (5 bits each)
      final scores = <int>[];
      for (int i = 0; i < gameCount; i++) {
        final encoded = reader.read(5);
        scores.add(encoded * 5); // Convert back to 0-100
      }

      // Name (20 bits = 4 chars × 5 bits)
      final nameChars = <int>[];
      for (int i = 0; i < 4; i++) {
        final value = reader.read(5);
        nameChars.add(value + 65); // 0=A, 25=Z
      }
      final name = String.fromCharCodes(nameChars);

      // Emoji index (8 bits)
      final emojiIndex = reader.read(8);

      // Checksum (12 bits)
      final storedChecksum = reader.read(12);

      // Verify checksum
      // Recalculate from data bytes (everything before checksum bits)
      final checksumBitOffset = 2 + 12 + 4 + (gameCount * 5) + 20 + 8;

      // The last data byte may contain some checksum bits that we need to mask out
      final fullDataBytes = checksumBitOffset ~/ 8;
      final extraBits = checksumBitOffset % 8;

      List<int> dataBytes;
      if (extraBits == 0) {
        // Checksum starts on a byte boundary
        dataBytes = bytes.sublist(0, fullDataBytes);
      } else {
        // Checksum starts mid-byte, need to mask out checksum bits from last byte
        dataBytes = bytes.sublist(0, fullDataBytes + 1).toList();
        // Clear the bits that belong to checksum (the low bits)
        final mask = (0xFF << (8 - extraBits)) & 0xFF;
        dataBytes[fullDataBytes] = dataBytes[fullDataBytes] & mask;
      }

      final calculatedChecksum = _calculateChecksum(dataBytes, daysSinceRef);

      final isValid = storedChecksum == calculatedChecksum;

      return ComparisonData(
        version: version,
        date: date,
        playerName: name,
        emojiIndex: emojiIndex,
        scores: scores,
        isValid: isValid,
        errorMessage: isValid ? null : 'Checksum mismatch',
      );
    } catch (e) {
      return ComparisonData.invalid('Decode error: $e');
    }
  }

  /// Convert encoded base64 to emoji string for sharing.
  static String toEmojiString(String base64Data, UserProfile profile) {
    final bytes = _fromBase64(base64Data);
    final emojis = StringBuffer();

    // Convert bytes to bits, then extract 6-bit chunks for emoji encoding
    final bits = _bytesToBits(bytes);
    for (int i = 0; i < bits.length; i += 6) {
      final remaining = bits.length - i;
      final chunkSize = remaining < 6 ? remaining : 6;
      int value = 0;
      for (int j = 0; j < chunkSize; j++) {
        if (bits[i + j]) {
          value |= (1 << (chunkSize - 1 - j));
        }
      }
      // Pad if less than 6 bits
      if (chunkSize < 6) {
        value <<= (6 - chunkSize);
      }
      emojis.write(EmojiLists.getEncodingEmoji(value));
    }

    return '${profile.displayName} ${emojis.toString()}';
  }

  /// Parse emoji string to extract the base64 data.
  static String? fromEmojiString(String emojiString) {
    try {
      // Find the space that separates profile from encoded data
      final spaceIndex = emojiString.indexOf(' ');
      if (spaceIndex == -1) {
        return null;
      }

      final encodedPart = emojiString.substring(spaceIndex + 1).trim();
      if (encodedPart.isEmpty) {
        return null;
      }

      // Parse emojis back to 6-bit values using grapheme clusters
      // This properly handles multi-codepoint emojis across platforms
      final values = <int>[];
      for (final grapheme in encodedPart.characters) {
        final index = EmojiLists.getEncodingIndex(grapheme);
        if (index != -1) {
          values.add(index);
        }
        // Skip unrecognized characters (whitespace, variation selectors, etc.)
      }

      if (values.isEmpty) {
        return null;
      }

      // Convert 6-bit values back to bytes
      final bits = <bool>[];
      for (final value in values) {
        for (int j = 5; j >= 0; j--) {
          bits.add((value >> j) & 1 == 1);
        }
      }

      final bytes = _bitsToBytes(bits);
      return _toBase64(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Calculate CRC-12 checksum with day salt.
  static int _calculateChecksum(List<int> data, int daySalt) {
    // Simple CRC-12 with polynomial 0x80D and day salt
    int crc = daySalt & 0xFFF;

    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0x80D;
        } else {
          crc >>= 1;
        }
      }
    }

    return crc & 0xFFF;
  }

  /// Convert bytes to URL-safe base64.
  static String _toBase64(List<int> bytes) {
    final base64 = base64Url.encode(Uint8List.fromList(bytes));
    // Remove padding
    return base64.replaceAll('=', '');
  }

  /// Convert URL-safe base64 to bytes.
  static List<int> _fromBase64(String encoded) {
    // Add padding if needed
    String padded = encoded;
    while (padded.length % 4 != 0) {
      padded += '=';
    }
    try {
      return base64Url.decode(padded);
    } catch (e) {
      return [];
    }
  }

  /// Convert bytes to list of bits.
  static List<bool> _bytesToBits(List<int> bytes) {
    final bits = <bool>[];
    for (final byte in bytes) {
      for (int i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1 == 1);
      }
    }
    return bits;
  }

  /// Convert list of bits to bytes.
  static List<int> _bitsToBytes(List<bool> bits) {
    final bytes = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8 && i + j < bits.length; j++) {
        if (bits[i + j]) {
          byte |= (1 << (7 - j));
        }
      }
      bytes.add(byte);
    }
    return bytes;
  }
}

/// Helper class for writing bits to a buffer.
class _BitWriter {
  final List<int> _bytes = [];
  int _bitPosition = 0;

  /// Write a value using the specified number of bits.
  void write(int value, int bits) {
    for (int i = bits - 1; i >= 0; i--) {
      final byteIndex = _bitPosition ~/ 8;
      final bitIndex = 7 - (_bitPosition % 8);

      while (_bytes.length <= byteIndex) {
        _bytes.add(0);
      }

      if ((value >> i) & 1 == 1) {
        _bytes[byteIndex] |= (1 << bitIndex);
      }
      _bitPosition++;
    }
  }

  /// Get the buffer as bytes.
  List<int> toBytes() => List.unmodifiable(_bytes);
}

/// Helper class for reading bits from a buffer.
class _BitReader {
  final List<int> _bytes;
  int _bitPosition = 0;

  _BitReader(this._bytes);

  /// Read a value using the specified number of bits.
  int read(int bits) {
    int value = 0;
    for (int i = 0; i < bits; i++) {
      final byteIndex = _bitPosition ~/ 8;
      final bitIndex = 7 - (_bitPosition % 8);

      if (byteIndex < _bytes.length) {
        if ((_bytes[byteIndex] >> bitIndex) & 1 == 1) {
          value |= (1 << (bits - 1 - i));
        }
      }
      _bitPosition++;
    }
    return value;
  }
}
