import 'package:flutter/material.dart';
import '../../widgets/preset_card.dart';
import '../focus_session/focus_session_screen.dart';
import '../history/history_screen.dart';
import '../preset_editor/preset_editor_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Completed sessions: 0'),
                    Text('Average session: No data yet'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Session Scout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Not enough history'),
                  ],
                ),
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