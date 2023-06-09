// home_page.dart

import 'package:flutter/material.dart';
import 'slide_puzzle.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('<background_image_url>'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Slide Puzzle'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SlidePuzzle(),
                ),
              );
            },
            child: const Text(
              'Play',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}