import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class SlidePuzzle extends StatefulWidget {
  final int gridSize;

  const SlidePuzzle({Key? key, this.gridSize = 3}) : super(key: key);

  @override
  _SlidePuzzleState createState() => _SlidePuzzleState();
}

class _SlidePuzzleState extends State<SlidePuzzle> {
  List<int> puzzleTiles = [];
  late int emptyTileIndex;
  late Timer _timer;
  int _start = 0;

  @override
  void initState() {
    super.initState();
    initializePuzzle();
    startTimer();
  }

  void initializePuzzle() {
    final int gridSize = widget.gridSize;
    final int tileCount = gridSize * gridSize;
    puzzleTiles = List<int>.generate(tileCount - 1, (index) => index + 1)..add(-1);
    emptyTileIndex = tileCount - 1;
    shufflePuzzle();
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
    if (isMoveValid(index)) {
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
    final int gridSize = widget.gridSize;
    final int row = index ~/ gridSize;
    final int col = index % gridSize;
    final int emptyRow = emptyTileIndex ~/ gridSize;
    final int emptyCol = emptyTileIndex % gridSize;
    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void checkIfPuzzleSolved() {
    final List<int> sortedTiles = List<int>.from(puzzleTiles)..sort();
    if (listEquals(puzzleTiles, sortedTiles)) {
      _timer.cancel(); // Stop the timer
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You solved the puzzle.'),
          actions: [
            TextButton(
              onPressed: () {
                shufflePuzzle();
                startTimer();
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int gridSize = widget.gridSize;
    final double tileSize = MediaQuery.of(context).size.width / gridSize;
    return Column(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: puzzleTiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
          ),
          itemBuilder: (context, index) {
            final int tileValue = puzzleTiles[index];
            return GestureDetector(
              onTap: () => moveTile(index),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2),
                color: tileValue == -1 ? Colors.grey[300] : Colors.blue,
                child: Text(
                  tileValue != -1 ? tileValue.toString() : '',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          formatTimerDuration(),
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
      ),
      body: SlidePuzzle(),
    ),
  ));
}
