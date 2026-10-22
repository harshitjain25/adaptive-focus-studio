import 'package:flutter/material.dart';

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
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
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            const Text(
              '25:00',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const LinearProgressIndicator(
              value: 0,
            ),

            const SizedBox(height: 16),

            const Text(
              'Ready to focus',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: null,
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