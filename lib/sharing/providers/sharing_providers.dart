import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../almanac/providers/almanac_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../cryptix/providers/cryptix_providers.dart';
import '../../cryptogram/providers/cryptogram_providers.dart';
import '../../doublet/core/utils/date_utils.dart';
import '../../doublet/providers/providers.dart' as doublet;
import '../../triverse/providers/triverse_providers.dart';
import '../models/comparison_data.dart';
import '../models/daily_scores.dart';
import '../models/user_profile.dart';
import '../services/score_codec.dart';
import '../services/sharing_storage_service.dart';

// ============ Storage Service ============

/// Sharing storage service for user profile persistence.
final sharingStorageProvider = Provider<SharingStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharingStorageService(prefs);
});

// ============ User Profile ============

/// User profile state notifier for managing name and emoji.
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final SharingStorageService _storage;

  UserProfileNotifier(this._storage) : super(_storage.loadProfile());

  /// Save a new profile.
  Future<void> setProfile(UserProfile profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }

  /// Clear the stored profile.
  Future<void> clearProfile() async {
    await _storage.clearProfile();
    state = null;
  }

  /// Check if a profile exists.
  bool get hasProfile => state != null;
}

/// Provider for user profile state.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final storage = ref.watch(sharingStorageProvider);
  return UserProfileNotifier(storage);
});

/// Whether the user has a profile set up.
final hasUserProfileProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile != null;
});

// ============ Today's Scores (Reactive) ============

/// Provider for today's Almanac score - watches game state for reactivity.
final almanacTodayScoreProvider = Provider<int?>((ref) {
  final gameState = ref.watch(almanacGameProvider);
  // Only return score if puzzle is solved
  if (gameState.state == AlmanacPuzzleState.solved) {
    return gameState.score;
  }
  // Fallback: check storage for today's score
  final todayScore = ref.watch(almanacTodaysStoredScoreProvider);
  return todayScore.valueOrNull;
});

/// Provider for today's Almanac score from storage.
final almanacTodaysStoredScoreProvider = FutureProvider<int?>((ref) async {
  final storage = ref.watch(almanacStorageServiceProvider);
  final now = DateTime.now().toUtc();
  final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return storage.getScoreForPuzzle(today);
});

/// Provider for today's Cryptix score - watches game state for reactivity.
final cryptixTodayScoreProvider = Provider<int?>((ref) {
  final gameState = ref.watch(cryptixGameProvider);
  if (gameState.todaysProgress?.solved == true) {
    return gameState.todaysProgress?.score;
  }
  // Fallback: check storage for progress solved today
  final storage = ref.watch(cryptixStorageProvider);
  final allProgress = storage.getAllProgress();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (final progress in allProgress.values) {
    if (progress.solved && progress.solvedAt != null) {
      final solvedDay = DateTime(
        progress.solvedAt!.year,
        progress.solvedAt!.month,
        progress.solvedAt!.day,
      );
      if (solvedDay == today) {
        return progress.score;
      }
    }
  }
  return null;
});

/// Provider for today's Cryptogram score - watches game state for reactivity.
final cryptogramTodayScoreProvider2 = Provider<int?>((ref) {
  final gameState = ref.watch(cryptogramGameProvider);
  if (gameState.isComplete) {
    return gameState.score;
  }
  // Fallback: check storage via the existing async provider
  final storageScore = ref.watch(cryptogramTodayScoreProvider);
  return storageScore.valueOrNull;
});

/// Provider for today's Doublet score - watches game state for reactivity.
/// Returns 0 if the user gave up (allows 5/5 completion with 0 points).
final doubletTodayScoreProvider = Provider<int?>((ref) {
  final gameState = ref.watch(doublet.gameStateProvider);
  // Check if there's an active completed game for today (success or gave up)
  if (gameState != null && gameState.isComplete) {
    return gameState.finalScore;
  }
  // Fallback: check storage for already completed today
  final storage = ref.watch(doublet.storageServiceProvider);
  final todayIndex = PuzzleDateUtils.getTodaysPuzzleIndex();
  final result = storage.getResultForPuzzle(todayIndex);
  if (result != null) {
    return result.score;
  }
  return null;
});

/// Provider for today's Triverse score - watches game state for reactivity.
final triverseTodayScoreProvider2 = Provider<int?>((ref) {
  final gameState = ref.watch(triverseGameProvider);
  if (gameState.isComplete) {
    return gameState.totalScore;
  }
  // Fallback: check storage for already completed today
  final scoreAsync = ref.watch(triverseTodaysScoreProvider);
  return scoreAsync.valueOrNull;
});

/// Aggregated today's scores for all games - fully reactive.
final todaysScoresProvider = Provider<DailyScores>((ref) {
  final almanacScore = ref.watch(almanacTodayScoreProvider);
  final cryptixScore = ref.watch(cryptixTodayScoreProvider);
  final cryptogramScore = ref.watch(cryptogramTodayScoreProvider2);
  final doubletScore = ref.watch(doubletTodayScoreProvider);
  final triverseScore = ref.watch(triverseTodayScoreProvider2);

  return DailyScores(
    date: DateTime.now().toUtc(),
    scores: {
      GameType.almanac: almanacScore,
      GameType.cryptix: cryptixScore,
      GameType.cryptogram: cryptogramScore,
      GameType.doublet: doubletScore,
      GameType.triverse: triverseScore,
    },
  );
});

// ============ Completion Status ============

/// Number of games completed today (0-5).
final todaysCompletionCountProvider = Provider<int>((ref) {
  final scores = ref.watch(todaysScoresProvider);
  return scores.completedCount;
});

/// Whether all games are completed today.
final isAllCompleteProvider = Provider<bool>((ref) {
  final scores = ref.watch(todaysScoresProvider);
  return scores.isComplete;
});

/// Completion status for a specific game.
final gameCompletionProvider = Provider.family<bool, GameType>((ref, game) {
  final scores = ref.watch(todaysScoresProvider);
  return scores.scores[game] != null;
});

// ============ Share Data ============

/// Encoded share data (base64) - only available when all games complete.
final shareDataProvider = Provider<String?>((ref) {
  final scores = ref.watch(todaysScoresProvider);
  final profile = ref.watch(userProfileProvider);

  if (!scores.isComplete || profile == null) {
    return null;
  }

  return ScoreCodec.encode(scores, profile);
});

/// Share URL - only available when all games complete and profile set.
final shareUrlProvider = Provider<String?>((ref) {
  final data = ref.watch(shareDataProvider);
  if (data == null) return null;
  return 'https://axiompuzzles.web.app/c/$data';
});

/// Share emoji string - only available when all games complete and profile set.
final shareEmojiStringProvider = Provider<String?>((ref) {
  final data = ref.watch(shareDataProvider);
  final profile = ref.watch(userProfileProvider);
  if (data == null || profile == null) return null;
  return ScoreCodec.toEmojiString(data, profile);
});

// ============ Comparison ============

/// Decode comparison data from a share string (URL data or emoji string).
ComparisonData decodeShareData(String input) {
  // Try to extract data from various formats
  String? data;

  // Check if it's a URL
  if (input.contains('axiompuzzles.web.app/c/')) {
    final uri = Uri.tryParse(input);
    if (uri != null) {
      final path = uri.path;
      if (path.startsWith('/c/')) {
        data = path.substring(3);
      }
    }
  }

  // Check if it's just the encoded data
  if (data == null && !input.contains(' ')) {
    data = input;
  }

  // Check if it's an emoji string (has space separator)
  if (data == null && input.contains(' ')) {
    data = ScoreCodec.fromEmojiString(input);
  }

  // If we still don't have data, try treating input as raw data
  data ??= input;

  return ScoreCodec.decode(data);
}
