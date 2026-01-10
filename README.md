# AXIOM

**Three daily puzzles. One app. Zero excuses.**

A collection of brain-teasing daily puzzles to keep your mind sharp. New challenges drop every day at midnight.

---

## The Games

### ALMANAC
*"A picture is worth a thousand guesses"*

Daily image puzzles where you identify what's hidden in the picture. Use hints wisely - they cost points!

### CRYPTIX
*"Where words go to get twisted"*

A daily cryptic crossword clue for wordplay enthusiasts. Decode anagrams, hidden words, and double definitions. British-style cryptics - because regular crosswords are too easy.

### DOUBLET
*"Change one letter, change your destiny"*

Transform one word into another, one letter at a time. Each step must be a real word. Inspired by Lewis Carroll's classic word ladder puzzles.

---

## Features

- New puzzles daily at midnight
- Score tracking with streaks
- Archive of past puzzles
- Dark mode (for those late-night puzzle sessions)
- Share your scores to flex on friends
- No ads, no accounts, no nonsense

---

## Tech Stack

- **Flutter** - Cross-platform goodness
- **Riverpod** - State management that doesn't make you cry
- **Firebase** - Puzzle delivery service
- **Dart** - The language, not the pub game

---

## Running Locally

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

---

## Project Structure

```
lib/
├── core/          # Shared stuff (theme, widgets, Firebase)
├── home/          # The hub where dreams begin
├── almanac/       # Image puzzle game
├── cryptix/       # Cryptic crossword game
├── doublet/       # Word ladder game
└── main.dart      # Where it all starts
```

---

## Note on Firebase Config

The Firebase configuration is included in the source code. This is intentional and safe for web apps - Firebase security is handled through Security Rules, not secret keys. These keys are always exposed in client-side applications.

---

## Made with care for Mills

*"The only puzzle we couldn't solve was why we made three puzzle games instead of one."*

---

## License

Do whatever you want with it. Just don't blame us when you're late for work because you were trying to beat your Doublet streak.
