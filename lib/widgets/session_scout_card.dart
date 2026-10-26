import 'package:flutter/material.dart';

class SessionScoutCard extends StatelessWidget {
  final int? suggestedMinutes;
  final VoidCallback? onApply;

  const SessionScoutCard({
    super.key,
    required this.suggestedMinutes,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final hasSuggestion = suggestedMinutes != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Scout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (!hasSuggestion)
              const Text(
                'Not enough history',
              ),

            if (hasSuggestion) ...[
              Text(
                'Suggested duration: $suggestedMinutes minutes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Based on your 3 most recent finished sessions with the same mood.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onApply,
                child: const Text('Apply'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}