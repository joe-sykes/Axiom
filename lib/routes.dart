import 'package:flutter/material.dart';

import 'core/constants/route_names.dart';

// Home
import 'home/screens/home_screen.dart';

// Core screens
import 'core/screens/privacy_screen.dart';

// Almanac screens
import 'almanac/screens/home_page.dart' as almanac;
import 'almanac/screens/archive_page.dart' as almanac;

// Cryptix screens
import 'cryptix/screens/home_screen.dart' as cryptix;
import 'cryptix/screens/archive_screen.dart' as cryptix;
import 'cryptix/screens/archive_puzzle_screen.dart' as cryptix;
import 'cryptix/screens/help_screen.dart' as cryptix;
import 'cryptix/models/puzzle.dart';

// Doublet screens
import 'doublet/screens/doublet_home.dart';
import 'doublet/screens/game_screen.dart';
import 'doublet/screens/archive_screen.dart' as doublet;
import 'doublet/screens/results_screen.dart';

// Triverse screens
import 'triverse/screens/triverse_home.dart';
import 'triverse/screens/triverse_play.dart';
import 'triverse/screens/triverse_archive.dart';

// Cryptogram screens
import 'cryptogram/screens/home_screen.dart' as cryptogram;
import 'cryptogram/screens/archive_screen.dart' as cryptogram;

/// Wraps a screen with a Title widget for SEO
Widget _withTitle(String title, Widget child) {
  return Title(
    title: title,
    color: Colors.black,
    child: child,
  );
}

/// Route generator for the Axiom app
Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Axiom hub
    case RouteNames.home:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Axiom - Daily Puzzle Games', const AxiomHomeScreen()),
        settings: settings,
      );

    // Unified privacy policy
    case RouteNames.privacy:
    case RouteNames.almanacPrivacy:
    case RouteNames.cryptixPrivacy:
    case RouteNames.doubletPrivacy:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Privacy Policy - Axiom', const PrivacyScreen()),
        settings: settings,
      );

    // Almanac routes
    case RouteNames.almanac:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Almanac - Daily Image Puzzle', const almanac.HomePage()),
        settings: settings,
      );
    case RouteNames.almanacArchive:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Almanac Archive - Past Puzzles', const almanac.ArchivePage()),
        settings: settings,
      );

    // Cryptix routes
    case RouteNames.cryptix:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Cryptix - Daily Cryptic Crossword Clue', const cryptix.HomeScreen()),
        settings: settings,
      );
    case RouteNames.cryptixArchive:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Cryptix Archive - Past Clues', const cryptix.ArchiveScreen()),
        settings: settings,
      );
    case RouteNames.cryptixArchivePuzzle:
      final args = settings.arguments as Map<String, dynamic>?;
      final puzzle = args?['puzzle'] as CryptixPuzzle?;
      final alreadySolved = args?['alreadySolved'] as bool? ?? false;
      if (puzzle == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No puzzle provided')),
          ),
          settings: settings,
        );
      }
      return MaterialPageRoute(
        builder: (_) => _withTitle('Cryptix Puzzle', cryptix.ArchivePuzzleScreen(
          puzzle: puzzle,
          alreadySolved: alreadySolved,
        )),
        settings: settings,
      );
    case RouteNames.cryptixHelp:
      return MaterialPageRoute(
        builder: (_) => _withTitle('How to Play Cryptix - Cryptic Crossword Guide', const cryptix.HelpScreen()),
        settings: settings,
      );

    // Doublet routes
    case RouteNames.doublet:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Doublet - Daily Word Ladder Puzzle', const DoubletHome()),
        settings: settings,
      );
    case RouteNames.doubletPlay:
      final args = settings.arguments as Map<String, dynamic>?;
      final isDaily = args?['isDaily'] as bool? ?? true;
      final puzzleIndex = args?['puzzleIndex'] as int?;
      return MaterialPageRoute(
        builder: (_) => _withTitle('Play Doublet', DoubletGameScreen(
          isDaily: isDaily,
          puzzleIndex: puzzleIndex,
        )),
        settings: settings,
      );
    case RouteNames.doubletArchive:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Doublet Archive - Past Word Ladders', const doublet.DoubletArchiveScreen()),
        settings: settings,
      );
    case RouteNames.doubletResults:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Doublet Results', const DoubletResultsScreen()),
        settings: settings,
      );

    // Triverse routes
    case RouteNames.triverse:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Triverse - Daily Trivia Challenge', const TriverseHome()),
        settings: settings,
      );
    case RouteNames.triversePlay:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Triverse - Play', const TriversePlay()),
        settings: settings,
      );
    case RouteNames.triverseArchive:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Triverse Archive', const TriverseArchiveScreen()),
        settings: settings,
      );
    case RouteNames.triversePrivacy:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Privacy Policy - Axiom', const PrivacyScreen()),
        settings: settings,
      );

    // Cryptogram routes
    case RouteNames.cryptogram:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Cryptogram - Daily Quote Puzzle', const cryptogram.CryptogramHomeScreen()),
        settings: settings,
      );
    case RouteNames.cryptogramArchive:
      return MaterialPageRoute(
        builder: (_) => _withTitle('Cryptogram Archive - Past Quote Puzzles', const cryptogram.CryptogramArchiveScreen()),
        settings: settings,
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Route not found: ${settings.name}'),
          ),
        ),
        settings: settings,
      );
  }
}
