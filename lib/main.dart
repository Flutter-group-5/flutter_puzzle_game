import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SlidePuzzle extends StatefulWidget {
  const SlidePuzzle({Key? key}) : super(key: key);

  @override
  _SlidePuzzleState createState() => _SlidePuzzleState();
}

class _SlidePuzzleState extends State<SlidePuzzle> {
  List<int> puzzleTiles = [];
  late int emptyTileIndex;
  late Timer _timer;
  int _start = 0;
  bool _solved = false;
  late int _gridSize;
  late double _tileSize;

  final List<String> difficultyLevels = ['3x3', '4x4', '5x5'];
  String _selectedDifficulty = '3x3';

  @override
  void initState() {
    super.initState();
    _gridSize = int.parse(_selectedDifficulty.split('x')[0]);
    initializePuzzle();
    startTimer();
  }

  void initializePuzzle() {
    final int tileCount = _gridSize * _gridSize;
    puzzleTiles = List<int>.generate(tileCount - 1, (index) => index + 1)..add(-1);
    emptyTileIndex = tileCount - 1;
    shufflePuzzle();
    _solved = false;
  }

  void shufflePuzzle() {
    final random = Random();
    for (int i = puzzleTiles.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = puzzleTiles[i];
      puzzleTiles[i] = puzzleTiles[j];
      puzzleTiles[j] = temp;
    }
    setState(() {});
  }

  void moveTile(int index) {
    if (!_solved && isMoveValid(index)) {
      setState(() {
        final temp = puzzleTiles[index];
        puzzleTiles[index] = puzzleTiles[emptyTileIndex];
        puzzleTiles[emptyTileIndex] = temp;
        emptyTileIndex = index;
      });
      checkIfPuzzleSolved();
    }
  }

  bool isMoveValid(int index) {
  final int row = index ~/ _gridSize;
  final int col = index % _gridSize;
  final int emptyRow = emptyTileIndex ~/ _gridSize;
  final int emptyCol = emptyTileIndex % _gridSize;
  
  // check if the tile is adjacent to the empty tile
  if ((row == emptyRow && (col - emptyCol).abs() == 1) || 
      (col == emptyCol && (row - emptyRow).abs() == 1)) {
    return true;
  }
  
  return false;
} 

  void checkIfPuzzleSolved() {
    final List<int> sortedTiles = List<int>.from(puzzleTiles)..sort();
    if (listEquals(puzzleTiles, sortedTiles)) {
      _timer.cancel(); // Stop the timer
      _solved = true;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You solved the puzzle in ${formatTimerDuration()}.'),
          actions: [
            TextButton(
              onPressed: () {
                shufflePuzzle();
                startTimer();
                _solved = false;
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() => _start++),
    );
  }

  String formatTimerDuration() {
    var duration = Duration(seconds: _start);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  void selectDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _gridSize = int.parse(_selectedDifficulty.split('x')[0]);
      _tileSize = MediaQuery.of(context).size.width / _gridSize;
      initializePuzzle();
    });
  }

  Widget buildDifficultyDropdown() {
    return DropdownButton(
      value: _selectedDifficulty,
      items: difficultyLevels.map((level) {
        return DropdownMenuItem(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: (value) => selectDifficulty(value as String),
    );
  }
  Widget buildTile(int index, double tileSize) {
  final int tileValue = puzzleTiles[index];
  final int row = index ~/ _gridSize;
  final int col = index % _gridSize;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    margin: EdgeInsets.all(tileSize * 0.02),
    decoration: BoxDecoration(
      color: tileValue == -1 ? Colors.transparent : Colors.blue,
      borderRadius: BorderRadius.circular(tileSize * 0.1),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(tileSize * 0.1),
      onTap: () => moveTile(index),
      child: Center(
        child: Text(
          tileValue == -1 ? '' : tileValue.toString(),
          style: TextStyle(
            fontSize: tileSize * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

  List<Widget> buildTiles(double tileSize) {
    final List<Widget> tiles = [];
    for (int i = 0; i < puzzleTiles.length; i++) {
      tiles.add(buildTile(i, tileSize));
    }
    return tiles;
  }

  Widget buildTimer() {
    return Text(
      formatTimerDuration(),
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tileSize = MediaQuery.of(context).size.width / _gridSize;
    return Scaffold(
      appBar: AppBar(
        title: Text('Slide Puzzle - $_selectedDifficulty'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16.0),
          buildDifficultyDropdown(),
          const SizedBox(height: 16.0),
          Container(
            width: _tileSize * _gridSize,
            height: _tileSize * _gridSize,
            child: GridView.count(
              crossAxisCount: _gridSize,
              children: buildTiles(_tileSize),
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
          const SizedBox(height: 16.0),
          buildTimer(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SlidePuzzle()));
}