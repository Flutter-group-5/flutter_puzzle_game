import 'package:flutter/material.dart';
import 'package:sample_gr_pr/screens/slide_puzzle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {s
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slide Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SlidePuzzleScreen(),
    );
  }
}
