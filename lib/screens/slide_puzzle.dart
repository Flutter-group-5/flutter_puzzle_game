import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SlidePuzzleScreen extends StatefulWidget {
  const SlidePuzzleScreen({Key? key}) : super(key: key);

  @override
  _SlidePuzzleScreenState createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  List<int> puzzleTiles = [];
  int emptyIndex = 0;
  bool _solved = false;
  bool _paused = false;
  late Timer _timer;
  int _start = 0;
  int _moves = 0;
  double _tileSize = 0.0;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    puzzleTiles = List<int>.generate(9, (index) => index + 1);
    puzzleTiles.shuffle();
    emptyIndex = puzzleTiles.indexOf(9);
    _solved = false;
    _paused = false;
    _start = 0;
    _moves = 0;
    startTimer();
  }

  void moveTile(int index) {
    if (!_paused && canMoveTile(index)) {
      setState(() {
        puzzleTiles[emptyIndex] = puzzleTiles[index];
        puzzleTiles[index] = 9;
        emptyIndex = index;
        _moves++;
      });
      checkIfPuzzleSolved();
    }
  }

  bool canMoveTile(int index) {
    final int row = index ~/ 3;
    final int col = index % 3;
    final int emptyRow = emptyIndex ~/ 3;
    final int emptyCol = emptyIndex % 3;
    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
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
          content: Text('You solved the puzzle in $_moves moves '
              'and $_start seconds.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_paused) {
        setState(() {
          _start++;
        });
      }
    });
  }

  void pauseGame() {
    _timer.cancel();
    setState(() {
      _paused = true;
    });
  }

  void resumeGame() {
    startTimer();
    setState(() {
      _paused = false;
    });
  }

  void giveUp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Give Up?'),
        content: const Text('Are you sure you want to give up?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startNewGame();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _tileSize = MediaQuery.of(context).size.width / 3;

    return WillPopScope(
      onWillPop: () async {
        final confirmExit = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exit'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        return confirmExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Slide Puzzle'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Time: ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Moves: $_moves',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final bool isColorfulTile = puzzleTiles[index] != 9;
                final Color tileColor =
                    isColorfulTile ? Colors.blue : Colors.grey.shade300;
                final Color textColor =
                    isColorfulTile ? Colors.white : Colors.black;
                return GestureDetector(
                  onTap: () => moveTile(index),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        puzzleTiles[index] == 9 ? '' : '${puzzleTiles[index]}',
                        style: TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (_paused) {
                  resumeGame();
                } else {
                  pauseGame();
                }
              },
              child: Icon(_paused ? Icons.play_arrow : Icons.pause),
            ),
            FloatingActionButton(
              onPressed: giveUp,
              child: const Icon(Icons.cancel),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
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
