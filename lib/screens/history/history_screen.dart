import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session_log.dart';
import '../../providers/repository_providers.dart';
import '../../services/insights_service.dart';
import '../../services/session_export_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final SessionExportService _exportService = SessionExportService();

  final InsightsService _insightsService = InsightsService();

  String _selectedMood = 'All';

  bool _isLoading = true;
  String? _error;

  List<SessionLog> _sessions = [];

  int _finishedCount = 0;
  double? _averageSeconds;

  final List<String> _moods = ['All', 'Focused', 'Calm', 'Tired', 'Motivated'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  List<SessionLog> get _filteredSessions {
    final sessions = _sessions.where((session) {
      if (_selectedMood == 'All') {
        return true;
      }

      return session.moodTagSnapshot == _selectedMood;
    }).toList();

    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return sessions;
  }

  Future<void> _loadHistory() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final repository = ref.read(sessionLogRepositoryProvider);

      final sessions = await repository.getAllSessionLogs();

      // Filter the sessions before sending them to the
      // background insights calculation.
      final sessionsForInsights = sessions.where((session) {
        if (_selectedMood == 'All') {
          return true;
        }

        return session.moodTagSnapshot == _selectedMood;
      }).toList();

      // InsightsService uses Flutter's compute() function,
      // so this calculation runs outside the main UI isolate.
      final insights = await _insightsService.calculateInsights(
        sessionsForInsights,
      );

      final average = insights.completedCount == 0
          ? null
          : insights.averageMinutes * 60;

      final count = insights.completedCount;

      if (!mounted) {
        return;
      }

      setState(() {
        _sessions = sessions;
        _averageSeconds = average;
        _finishedCount = count;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (remainingSeconds == 0) {
      return '$minutes min';
    }

    return '$minutes min $remainingSeconds sec';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  Future<void> _changeMood(String value) async {
    setState(() {
      _selectedMood = value;
    });

    await _loadHistory();
  }

  Future<void> _exportSummary() async {
    try {
      final averageMinutes = (_averageSeconds ?? 0) / 60;

      final file = await _exportService.exportSummary(
        totalSessions: _finishedCount,
        averageMinutes: averageMinutes.round(),
        selectedMood: _selectedMood,
        scoutBaselineMinutes: 25,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Summary exported successfully:\n${file.path}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  Future<void> _deleteSession(SessionLog session) async {
    if (session.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Session?'),
          content: const Text(
            'This session will be permanently '
            'removed from your history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final repository = ref.read(sessionLogRepositoryProvider);

      final deletedRows = await repository.deleteSessionLog(session.id!);

      if (!mounted) {
        return;
      }

      if (deletedRows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted successfully.')),
        );

        await _loadHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session could not be deleted.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete session: $error')),
      );
    }
  }

  Future<void> _editNote(SessionLog session) async {
    if (session.id == null) {
      return;
    }

    String noteValue = session.note ?? '';

    final newNote = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Session Note'),
          content: TextFormField(
            initialValue: noteValue,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Add a short note about this session',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              noteValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, noteValue.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newNote == null) {
      return;
    }

    try {
      final repository = ref.read(sessionLogRepositoryProvider);

      final updatedSession = session.copyWith(note: newNote);

      final updatedRows = await repository.updateSessionLog(updatedSession);

      if (!mounted) {
        return;
      }

      if (updatedRows > 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Session note updated.')));

        await _loadHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session could not be updated.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update session: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _filteredSessions;

    final averageMinutes = (_averageSeconds ?? 0) / 60;

    return Scaffold(
      appBar: AppBar(title: const Text('History & Insights')),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Average Completed Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (_isLoading)
                      const LinearProgressIndicator()
                    else if (_finishedCount == 0)
                      const Text(
                        'No completed sessions yet',
                        style: TextStyle(fontSize: 16),
                      )
                    else
                      Text(
                        '${averageMinutes.toStringAsFixed(1)} minutes',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 4),

                    Text(
                      'Sample count: $_finishedCount',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _selectedMood,
              decoration: const InputDecoration(
                labelText: 'Filter by Mood',
                border: OutlineInputBorder(),
              ),
              items: _moods.map((mood) {
                return DropdownMenuItem<String>(value: mood, child: Text(mood));
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      _changeMood(value);
                    },
            ),

            const SizedBox(height: 24),

            const Text(
              'Session History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_isLoading && _error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 42),

                      const SizedBox(height: 12),

                      const Text(
                        'Unable to load history',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(_error!, textAlign: TextAlign.center),

                      const SizedBox(height: 12),

                      OutlinedButton(
                        onPressed: _loadHistory,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoading && _error == null && filteredSessions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 42),

                      SizedBox(height: 12),

                      Text(
                        'No session history yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Completed focus sessions '
                        'will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoading && _error == null)
              ...filteredSessions.map((session) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        session.status.toLowerCase() == 'finished'
                            ? Icons.check
                            : Icons.timer,
                      ),
                    ),
                    title: Text(
                      session.moodTagSnapshot,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        Text(
                          'Duration: '
                          '${_formatDuration(session.completedSeconds)}',
                        ),

                        Text(
                          'Date: '
                          '${_formatDate(session.startedAt)}',
                        ),

                        Text('Status: ${session.status}'),

                        if (session.note != null &&
                            session.note!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Note: ${session.note}'),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editNote(session);
                        }

                        if (value == 'delete') {
                          _deleteSession(session);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit Note')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportSummary,
              icon: const Icon(Icons.download),
              label: const Text('Export Session Summary'),
            ),

            const SizedBox(height: 12),

            const Text(
              'The exported file is stored locally '
              'on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
