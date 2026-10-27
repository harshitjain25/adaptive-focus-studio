import 'package:flutter/material.dart';

import '../../models/session_log.dart';
import '../../smart_helper/session_scout.dart';
import '../../widgets/preset_card.dart';
import '../../widgets/session_scout_card.dart';
import '../focus_session/focus_session_screen.dart';
import '../history/history_screen.dart';
import '../preset_editor/preset_editor_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleSessions = [
      SessionLog(
        presetId: 1,
        startedAt: DateTime(2026, 10, 20),
        completedSeconds: 20 * 60,
        moodTagSnapshot: 'Focused',
        status: 'finished',
        source: 'timer',
      ),
      SessionLog(
        presetId: 1,
        startedAt: DateTime(2026, 10, 21),
        completedSeconds: 30 * 60,
        moodTagSnapshot: 'Focused',
        status: 'finished',
        source: 'timer',
      ),
      SessionLog(
        presetId: 1,
        startedAt: DateTime(2026, 10, 22),
        completedSeconds: 25 * 60,
        moodTagSnapshot: 'Focused',
        status: 'finished',
        source: 'timer',
      ),
    ];

    final suggestedMinutes = SessionScout.suggestDuration(
      sessions: sampleSessions,
      moodTag: 'Focused',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Your Focus Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Plan a session, stay focused, and review your progress.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            SessionScoutCard(
              suggestedMinutes: suggestedMinutes,
              onApply: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Suggested duration: $suggestedMinutes minutes',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Mood Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: 'All',
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Focused',
                  child: Text('Focused'),
                ),
                DropdownMenuItem(
                  value: 'Calm',
                  child: Text('Calm'),
                ),
                DropdownMenuItem(
                  value: 'Tired',
                  child: Text('Tired'),
                ),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Presets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            PresetCard(
              label: 'Machine Learning Study',
              mood: 'Focused',
              durationMinutes: 25,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FocusSessionScreen(),
                  ),
                );
              },
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresetEditorScreen(),
                  ),
                );
              },
              onDelete: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Preset?'),
                      content: const Text(
                        'This preset cannot be deleted if it still has session history.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Delete will be connected to the repository later.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Preset'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresetEditorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.timer),
              label: const Text('Focus Session'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FocusSessionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('History & Insights'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}