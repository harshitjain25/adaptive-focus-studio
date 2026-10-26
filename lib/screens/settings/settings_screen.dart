import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unable to load settings.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Session Preferences',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Default duration: ${settings.defaultDuration} minutes',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Slider(
                value: settings.defaultDuration.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                label: '${settings.defaultDuration} min',
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setDefaultDuration(value.round());
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Reduced Motion'),
                subtitle: const Text(
                  'Use fewer animations throughout the app.',
                ),
                value: settings.reducedMotion,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setReducedMotion(value);
                },
              ),

              const Divider(),

              SwitchListTile(
                title: const Text('Sound'),
                subtitle: const Text(
                  'Allow optional session sounds.',
                ),
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setSoundEnabled(value);
                },
              ),

              const Divider(),

              SwitchListTile(
                title: const Text('Reminders'),
                subtitle: const Text(
                  'Allow local focus reminders.',
                ),
                value: settings.remindersEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setRemindersEnabled(value);
                },
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your settings are saved locally on this device.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}