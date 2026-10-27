import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/focus_preset.dart';
import '../../models/session_log.dart';
import '../../providers/repository_providers.dart';
import '../../smart_helper/session_scout.dart';
import '../../widgets/preset_card.dart';
import '../../widgets/session_scout_card.dart';
import '../focus_session/focus_session_screen.dart';
import '../history/history_screen.dart';
import '../preset_editor/preset_editor_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedMood = 'All';

  bool _isLoadingPresets = true;
  String? _presetError;

  bool _isLoadingScout = false;
  String? _scoutError;

  List<FocusPreset> _presets = [];
  List<SessionLog> _recentScoutSessions = [];

  final List<String> _moods = ['All', 'Focused', 'Calm', 'Tired', 'Motivated'];

  @override
  void initState() {
    super.initState();

    _loadPresets();
  }

  Future<void> _loadPresets() async {
    if (mounted) {
      setState(() {
        _isLoadingPresets = true;
        _presetError = null;
      });
    }

    try {
      final repository = ref.read(focusPresetRepositoryProvider);

      final presets = await repository.getAllPresets();

      if (!mounted) {
        return;
      }

      setState(() {
        _presets = presets;
        _isLoadingPresets = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _presetError = error.toString();
        _isLoadingPresets = false;
      });
    }
  }

  Future<void> _loadScoutSessions() async {
    if (_selectedMood == 'All') {
      if (mounted) {
        setState(() {
          _recentScoutSessions = [];
          _scoutError = null;
          _isLoadingScout = false;
        });
      }

      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingScout = true;
        _scoutError = null;
      });
    }

    try {
      final repository = ref.read(sessionLogRepositoryProvider);

      final sessions = await repository.getRecentFinishedSessions(
        moodTag: _selectedMood,
        limit: 3,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _recentScoutSessions = sessions;
        _isLoadingScout = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _scoutError = error.toString();
        _recentScoutSessions = [];
        _isLoadingScout = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadPresets();
    await _loadScoutSessions();
  }

  List<FocusPreset> get _filteredPresets {
    if (_selectedMood == 'All') {
      return _presets;
    }

    return _presets.where((preset) {
      return preset.moodTag == _selectedMood;
    }).toList();
  }

  int? get _suggestedMinutes {
    if (_selectedMood == 'All') {
      return null;
    }

    return SessionScout.suggestDuration(
      sessions: _recentScoutSessions,
      moodTag: _selectedMood,
    );
  }

  Future<void> _changeMood(String value) async {
    setState(() {
      _selectedMood = value;
    });

    await _loadScoutSessions();
  }

  Future<void> _openCreatePreset() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const PresetEditorScreen()),
    );

    if (saved == true) {
      await _refreshDashboard();
    }
  }

  Future<void> _openEditPreset(FocusPreset preset) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PresetEditorScreen(preset: preset),
      ),
    );

    if (saved == true) {
      await _refreshDashboard();
    }
  }

  Future<void> _deletePreset(FocusPreset preset) async {
    if (preset.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete this preset.')),
      );

      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Preset?'),
          content: Text(
            'Delete "${preset.label}"?\n\n'
            'A preset with existing session history '
            'cannot be deleted.',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      final repository = ref.read(focusPresetRepositoryProvider);

      final deletedRows = await repository.deletePreset(preset.id!);

      if (!mounted) {
        return;
      }

      if (deletedRows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preset deleted successfully.')),
        );

        await _loadPresets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preset could not be deleted.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This preset cannot be deleted because '
            'it has session history.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPresets = _filteredPresets;
    final suggestedMinutes = _suggestedMinutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Your Focus Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Plan a session, stay focused, '
              'and review your progress.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            if (_selectedMood == 'All')
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Scout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select a mood to get a '
                        'personalized duration suggestion.',
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoadingScout)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_scoutError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Session Scout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Unable to load recommendation.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadScoutSessions,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SessionScoutCard(
                suggestedMinutes: suggestedMinutes,
                onApply: suggestedMinutes == null
                    ? null
                    : () async {
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PresetEditorScreen(
                              initialMood: _selectedMood,
                              initialDurationMinutes: suggestedMinutes,
                            ),
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (saved == true) {
                          await _refreshDashboard();
                        }
                      },
              ),
            const SizedBox(height: 24),

            const Text(
              'Mood Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedMood,
              items: _moods.map((mood) {
                return DropdownMenuItem<String>(value: mood, child: Text(mood));
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                _changeMood(value);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Presets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (_isLoadingPresets)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_isLoadingPresets && _presetError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Unable to load presets.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_presetError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadPresets,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoadingPresets &&
                _presetError == null &&
                filteredPresets.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.bookmark_border, size: 42),
                      const SizedBox(height: 12),
                      Text(
                        _selectedMood == 'All'
                            ? 'No presets yet'
                            : 'No $_selectedMood presets',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedMood == 'All'
                            ? 'Create your first focus preset.'
                            : 'Try another mood or create a new preset.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoadingPresets && _presetError == null)
              ...filteredPresets.map(
                (preset) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PresetCard(
                    label: preset.label,
                    mood: preset.moodTag,
                    durationMinutes: preset.plannedSeconds ~/ 60,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FocusSessionScreen(preset: preset),
                        ),
                      );
                    },
                    onEdit: () {
                      _openEditPreset(preset);
                    },
                    onDelete: () {
                      _deletePreset(preset);
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Preset'),
              onPressed: _openCreatePreset,
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('History & Insights'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );

                if (!mounted) {
                  return;
                }

                await _loadScoutSessions();
              },
            ),
          ],
        ),
      ),
    );
  }
}
