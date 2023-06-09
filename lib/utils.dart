// utils.dart

import 'dart:async';

String formatTimerDuration(int elapsedSeconds) {
  final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

void startTimer(Timer timer, Function setState) {
  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {});
  });
}