import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (_) => IntroScreen(),
      '/game': (_) => SlidePuzzle(),
    },
  ));
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Slide Puzzle!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'To begin, select a difficulty level:',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButton(
              value: '3x3',
              items: [
                DropdownMenuItem(
                  value: '3x3',
                  child: const Text('3x3'),
                ),
                DropdownMenuItem(
                  value: '4x4',
                  child: const Text('4x4'),
                ),
                DropdownMenuItem(
                  value: '5x5',
                  child: const Text('5x5'),
                ),
              ],
              onChanged: (value) {
                Navigator.pushReplacementNamed(context, '/game',
                    arguments: int.parse(value.toString().split('x')[0]));
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool _solved = false;
  late int _gridSize;
  late double _tileSize;

  @override
  void initState() {
    super.initState();
    _gridSize = widget.gridSize;
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      );
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        _start++;
      });
    });
  }

  String formatTimerDuration() {
    final Duration duration = Duration(seconds: _start);
    final String minutes = (duration.inMinutes).toString().padLeft(2, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    _tileSize = MediaQuery.of(context).size.width / _gridSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Time: ${formatTimerDuration()}',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
            ),
            itemCount: puzzleTiles.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => moveTile(index),
                child: Container(
                  width: _tileSize,
                  height: _tileSize,
                  decoration: BoxDecoration(
                    color: puzzleTiles[index] == -1
                        ? Colors.white
                        : Colors.grey[300],
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      puzzleTiles[index] != -1 ? '${puzzleTiles[index]}' : '',
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: shufflePuzzle,
            child: const Text('Shuffle'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
