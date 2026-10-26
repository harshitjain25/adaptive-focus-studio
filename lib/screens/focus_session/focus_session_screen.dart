import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/timer_provider.dart';

class FocusSessionScreen extends ConsumerWidget {
  const FocusSessionScreen({super.key});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStatusText(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return 'Stay focused';
      case TimerStatus.paused:
        return 'Session paused';
      case TimerStatus.finished:
        return 'Session finished';
      case TimerStatus.idle:
        return 'Ready to focus';
    }
  }

  Future<void> _showResetDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Session?'),
          content: const Text(
            'This will reset the timer back to the planned duration.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      ref.read(focusTimerProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);

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
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            Text(
              _formatTime(timerState.remainingSeconds),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: timerState.progress,
            ),

            const SizedBox(height: 16),

            Text(
              _getStatusText(timerState.status),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: timerState.status == TimerStatus.running ||
                      timerState.status == TimerStatus.finished
                  ? null
                  : timerState.status == TimerStatus.paused
                      ? timerNotifier.resume
                      : timerNotifier.start,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                timerState.status == TimerStatus.paused
                    ? 'Resume'
                    : 'Start',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: timerState.status == TimerStatus.running
                  ? timerNotifier.pause
                  : null,
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: timerState.hasStarted &&
                      timerState.status != TimerStatus.finished
                  ? () {
                      timerNotifier.finish();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session finished.'),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Finish'),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: timerState.hasStarted
                  ? () {
                      _showResetDialog(context, ref);
                    }
                  : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}