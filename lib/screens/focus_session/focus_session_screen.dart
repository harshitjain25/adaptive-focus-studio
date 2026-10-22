import 'dart:async';

import 'package:flutter/material.dart';

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  Timer? _timer;

  static const int _plannedSeconds = 25 * 60;

  int _remainingSeconds = _plannedSeconds;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;

  void _startTimer() {
    if (_isRunning || _remainingSeconds <= 0) {
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isFinished = false;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
            _isPaused = false;
            _isFinished = true;
          });
        }
      },
    );
  }

  void _pauseTimer() {
    if (!_isRunning) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    if (!_isPaused) {
      return;
    }

    _startTimer();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    if (_isFinished) {
      return 'Session finished';
    }

    if (_isRunning) {
      return 'Stay focused';
    }

    if (_isPaused) {
      return 'Session paused';
    }

    return 'Ready to focus';
  }

  double _getProgress() {
    return 1 - (_remainingSeconds / _plannedSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Machine Learning Study',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Mood: Focused',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              _formatTime(_remainingSeconds),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: _getProgress(),
            ),

            const SizedBox(height: 16),

            Text(
              _getStatusText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: _isRunning || _isFinished
                  ? null
                  : _isPaused
                      ? _resumeTimer
                      : _startTimer,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                _isPaused ? 'Resume' : 'Start',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isRunning ? _pauseTimer : null,
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check),
              label: const Text('Finish'),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}