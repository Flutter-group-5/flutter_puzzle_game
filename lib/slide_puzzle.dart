// slide_puzzle.dart

// ignore_for_file: unused_field

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
  bool _paused = false;
  final int _gridSize = 3;
  late double _tileSize;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    initializePuzzle();
    startTimer();
  }

  

  void initializePuzzle() {
    final int tileCount = _gridSize * _gridSize;
    puzzleTiles = List<int>.generate(tileCount - 1, (index) => index + 1)
      ..add(-1);
    emptyTileIndex = tileCount - 1;
    shufflePuzzle();
    _solved = false;
    _moves = 0;
  }

  void shufflePuzzle() {
    _start = 0;
    final random = Random();
    for (int i = puzzleTiles.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = puzzleTiles[i];
      puzzleTiles[i] = puzzleTiles[j];
      puzzleTiles[j] = temp;
    }

    emptyTileIndex = puzzleTiles.indexOf(-1);
    _paused = false;
    _moves = 0;

    setState(() {});
  }

  void moveTile(int index) {
    if (!_solved && !_paused && isMoveValid(index)) {
      if (!_timer.isActive) {
        startTimer();
      }
      setState(() {
        final temp = puzzleTiles[index];
        puzzleTiles[index] = puzzleTiles[emptyTileIndex];
        puzzleTiles[emptyTileIndex] = temp;
        emptyTileIndex = index;
        _moves++;
      });
      checkIfPuzzleSolved();
    }
  }

  bool isMoveValid(int index) {
    final int row = index ~/ _gridSize;
    final int col = index % _gridSize;
    final int emptyRow = emptyTileIndex ~/ _gridSize;
    final int emptyCol = emptyTileIndex % _gridSize;
    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      return true;
    }

    return false;
  }

  void checkIfPuzzleSolved() {
  final List<int> sortedTiles = List<int>.from(puzzleTiles)..sort();
  if (listEquals(puzzleTiles, sortedTiles)) {
    _timer.cancel();
    _solved = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You solved the puzzle in ${formatTimerDuration()} with $_moves moves.'),
        actions: [
          TextButton(
            onPressed: () {
              shufflePuzzle();
              startTimer();
              _solved = false;
              Navigator.pop(context);
              shufflePuzzle();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _start++;
      });
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _timer.cancel();
      } else {
        startTimer();
      }
    });
  }

  String formatTimerDuration() {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _tileSize = size.width / _gridSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
        actions: [
          IconButton(
            onPressed: _togglePause,
            icon: _paused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (puzzleTiles[index] == -1) {
                  return Container();
                }
                return GestureDetector(
                  onTap: () => moveTile(index),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: puzzleTiles[index] == -1
                              ? Colors.grey[300]
                              : Colors.blue[600],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      child: Text(
                        puzzleTiles[index].toString(),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
              itemCount: puzzleTiles.length,
            ),
            const SizedBox(height: 16),
            Text(
              'Moves: $_moves',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              formatTimerDuration(),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: shufflePuzzle,
              child: const Text('Restart'), 
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
