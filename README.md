# AXIOM

**Five daily puzzles. One app. Zero excuses.**

A collection of brain-teasing daily puzzles to keep your mind sharp. New challenges drop every day at midnight.

**Play now:** [axiompuzzles.web.app](https://axiompuzzles.web.app)

---

## The Games

### ALMANAC
*"Riddle me this"*

Daily logic puzzles where you solve riddles and clues. Read carefully, think creatively, and use hints wisely - they cost points!

### CRYPTIX
*"Where words go to get twisted"*

A daily cryptic crossword clue for wordplay enthusiasts. Decode anagrams, hidden words, and double definitions. British-style cryptics - because regular crosswords are too easy.

### CRYPTOGRAM
*"Crack the code, reveal the quote"*

Classic substitution cipher puzzles featuring famous quotes. Each letter has been replaced with another - figure out the pattern to decode the message.

### DOUBLET
*"Change one letter, change your destiny"*

Transform one word into another, one letter at a time. Each step must be a real word. Inspired by Lewis Carroll's classic word ladder puzzles.

### TRIVERSE
*"Seven questions. Three categories. One shot."*

Daily trivia challenge with 7 multiple-choice questions across 3 categories. Beat the clock for bonus points and use your 50/50 lifeline wisely - you only get one!

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
├── cryptogram/    # Substitution cipher game
├── doublet/       # Word ladder game
├── triverse/      # Daily trivia game
└── main.dart      # Where it all starts
```

---

## Note on Firebase Config

The Firebase configuration is included in the source code. This is intentional and safe for web apps - Firebase security is handled through Security Rules, not secret keys. These keys are always exposed in client-side applications.

---

## Made with care for Mills

*"The only puzzle we couldn't solve was why we made five puzzle games instead of one."*

---

## License

Do whatever you want with it. Just don't blame us when you're late for work because you were trying to beat your Doublet streak.
