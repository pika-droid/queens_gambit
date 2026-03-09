# Queen's Gambit

A beautifully designed, interactive Flutter application for exploring and solving the classic **N-Queens Problem**. 

The N-Queens puzzle is the problem of placing N chess queens on an N×N chessboard so that no two queens threaten each other. This app allows users to interactively place queens, visualize safe squares, solve the puzzle automatically, and challenge themselves in a dedicated Puzzle Mode.

<p align="center">
  <img src="logo.png" alt="Queen's Gambit Logo" width="200" />
</p>

## Features

- **Interactive Chessboard**: Tap to place queens. The board dynamically updates to show which squares are under attack and which are safe.
- **Dynamic Board Size**: Easily adjust the board size (N) from 4x4 up to larger, more complex dimensions.
- **Puzzle Mode**: A challenging game mode where random queens are "locked" on the board, and the user must figure out how to place the remaining queens to solve the puzzle.
- **Auto-Solver**: Stuck? Use the built-in N-Queens solver algorithm to instantly find a valid solution for the current board size.
- **Visual Feedback**: Sleek UI with animations when placing queens, highlighting threats, and celebrating a solved board.
- **Performance Optimized**: Built using efficient state management (BLoC pattern) to ensure no frame drops even on larger board sizes.

## 🛠 Tech Stack & Architecture

- **Framework**: Flutter / Dart
- **State Management**: flutter_bloc (BLoC Pattern)
- **Architecture Highlights**:
  - `GameBloc`: Manages the central state of the game, including the board configuration, current mode, and solving status.
  - `NQueensSolver`: An optimized backtracking algorithm customized for this game to find valid solutions.
  - **Custom Widgets**: Highly optimized `ChessBoard`, `BoardSquare`, and `StatsBar` widgets that minimize rebuilds using `buildWhen` logic.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An IDE with Flutter support (VS Code, Android Studio, or IntelliJ).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/pika-droid/queens_gambit.git
   cd queens_gambit
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Building for Production (Android)

To generate release APKs, run:
```bash
flutter build apk --release
```
This will produce a universal APK. To build split architecture APKs (for smaller app sizes), use:
```bash
flutter build apk --split-per-abi --release
```

## 🎮 How to Play

- **Free Play**: Select your desired board size. Tap on any safe (unhighlighted) square to place a Queen. If you place N Queens successfully, you win!
- **Puzzle Mode**: Tap the "Puzzle" icon. A board will be generated with a few pre-locked Queens. Your objective is to place the rest of the queens without triggering any attacks.

## Contributing

Feel free to fork this project and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License.
