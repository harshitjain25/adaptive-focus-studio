import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  finished,
}

class FocusTimerState {
  final int plannedSeconds;
  final int remainingSeconds;
  final TimerStatus status;

  const FocusTimerState({
    required this.plannedSeconds,
    required this.remainingSeconds,
    required this.status,
  });

  double get progress {
    if (plannedSeconds == 0) {
      return 0;
    }

    return 1 - (remainingSeconds / plannedSeconds);
  }

  bool get hasStarted {
    return remainingSeconds < plannedSeconds ||
        status == TimerStatus.running ||
        status == TimerStatus.paused ||
        status == TimerStatus.finished;
  }

  FocusTimerState copyWith({
    int? plannedSeconds,
    int? remainingSeconds,
    TimerStatus? status,
  }) {
    return FocusTimerState(
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}

class FocusTimerNotifier extends Notifier<FocusTimerState> {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    const plannedSeconds = 25 * 60;

    return const FocusTimerState(
      plannedSeconds: plannedSeconds,
      remainingSeconds: plannedSeconds,
      status: TimerStatus.idle,
    );
  }

  void start() {
    if (state.status == TimerStatus.running ||
        state.remainingSeconds <= 0) {
      return;
    }

    _timer?.cancel();

    state = state.copyWith(
      status: TimerStatus.running,
    );

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state.remainingSeconds > 1) {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
          );
        } else {
          timer.cancel();

          state = state.copyWith(
            remainingSeconds: 0,
            status: TimerStatus.finished,
          );
        }
      },
    );
  }

  void pause() {
    if (state.status != TimerStatus.running) {
      return;
    }

    _timer?.cancel();

    state = state.copyWith(
      status: TimerStatus.paused,
    );
  }

  void resume() {
    if (state.status != TimerStatus.paused) {
      return;
    }

    start();
  }

  void finish() {
    if (state.status == TimerStatus.finished ||
        state.status == TimerStatus.idle) {
      return;
    }

    _timer?.cancel();

    state = state.copyWith(
      status: TimerStatus.finished,
    );
  }

  void reset() {
    _timer?.cancel();

    state = state.copyWith(
      remainingSeconds: state.plannedSeconds,
      status: TimerStatus.idle,
    );
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerNotifier, FocusTimerState>(
  FocusTimerNotifier.new,
);