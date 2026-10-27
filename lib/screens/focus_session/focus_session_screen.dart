import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/focus_preset.dart';
import '../../models/session_log.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/notification_service.dart';

class FocusSessionScreen extends ConsumerStatefulWidget {
  final FocusPreset preset;

  const FocusSessionScreen({
    super.key,
    required this.preset,
  });

  @override
  ConsumerState<FocusSessionScreen> createState() =>
      _FocusSessionScreenState();
}

class _FocusSessionScreenState
    extends ConsumerState<FocusSessionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _completionController;
  late final Animation<double> _completionScale;

  DateTime? _startedAt;
  bool _sessionSaved = false;

  @override
void initState() {
  super.initState();

  _completionController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  _completionScale = CurvedAnimation(
    parent: _completionController,
    curve: Curves.easeOutBack,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) {
      return;
    }

    ref
        .read(focusTimerProvider.notifier)
        .configure(widget.preset.plannedSeconds);
  });
}

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

  Future<void> _showResetDialog() async {
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

      _completionController.reset();

      _startedAt = null;
      _sessionSaved = false;
    }
  }

  void _playCompletionAnimation(bool reducedMotion) {
    if (reducedMotion) {
      _completionController.value = 1;
      return;
    }

    _completionController.forward(from: 0);
  }

  Future<void> _showCompletionNotificationIfEnabled() async {
    final settingsAsync = ref.read(settingsProvider);

    final remindersEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.remindersEnabled,
      orElse: () => false,
    );

    if (!remindersEnabled) {
      return;
    }

    await NotificationService.instance
        .showFocusCompleteNotification();
  }

  Future<void> _saveFinishedSession(
    FocusTimerState timerState,
  ) async {
    if (_sessionSaved) {
      return;
    }

    final presetId = widget.preset.id;

    if (presetId == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save session because the preset is not saved.',
          ),
        ),
      );

      return;
    }

    _sessionSaved = true;

    final completedSeconds =
        timerState.plannedSeconds - timerState.remainingSeconds;

    final log = SessionLog(
      presetId: presetId,
      startedAt: _startedAt ?? DateTime.now(),
      completedSeconds: completedSeconds,
      moodTagSnapshot: widget.preset.moodTag,
      status: 'finished',
      source: 'timer',
    );

    try {
      final repository = ref.read(
        sessionLogRepositoryProvider,
      );

      final id = await repository.createSessionLog(log);

      if (id <= 0) {
        throw Exception('Session log was not created.');
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session finished and saved.',
          ),
        ),
      );
    } catch (error) {
      _sessionSaved = false;

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save session: $error',
          ),
        ),
      );
    }
  }

  Future<void> _finishSession() async {
    ref.read(focusTimerProvider.notifier).finish();
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(
      focusTimerProvider.notifier,
    );

    final settingsAsync = ref.watch(settingsProvider);

    final reducedMotion = settingsAsync.maybeWhen(
      data: (settings) => settings.reducedMotion,
      orElse: () => false,
    );

    ref.listen<FocusTimerState>(
      focusTimerProvider,
      (previous, next) {
        if (previous?.status == TimerStatus.idle &&
            next.status == TimerStatus.running) {
          _startedAt = DateTime.now();
          _sessionSaved = false;
        }

        if (previous?.status != TimerStatus.finished &&
            next.status == TimerStatus.finished) {
          _playCompletionAnimation(reducedMotion);

          _saveFinishedSession(next);

          _showCompletionNotificationIfEnabled();
        }

        if (next.status == TimerStatus.idle) {
          _completionController.reset();
        }
      },
    );

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

            Text(
              widget.preset.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Mood: ${widget.preset.moodTag}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            if (timerState.status == TimerStatus.finished)
              ScaleTransition(
                scale: _completionScale,
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),

            if (timerState.status == TimerStatus.finished)
              const SizedBox(height: 16),

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

            AnimatedContainer(
              duration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: timerState.status == TimerStatus.running
                    ? Colors.green.withValues(alpha: 0.12)
                    : timerState.status == TimerStatus.paused
                        ? Colors.orange.withValues(alpha: 0.12)
                        : timerState.status == TimerStatus.finished
                            ? Colors.blue.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.10),
              ),
              child: Text(
                _getStatusText(timerState.status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed:
                  timerState.status == TimerStatus.running ||
                          timerState.status == TimerStatus.finished
                      ? null
                      : timerState.status ==
                              TimerStatus.paused
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
              onPressed:
                  timerState.status == TimerStatus.running
                      ? timerNotifier.pause
                      : null,
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: timerState.hasStarted &&
                      timerState.status != TimerStatus.finished
                  ? _finishSession
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Finish'),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: timerState.hasStarted
                  ? _showResetDialog
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