import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/providers/timer_provider.dart';

void main() {
  group('FocusTimerNotifier', () {
    test('starts with 25 minutes and idle status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(focusTimerProvider);

      expect(state.plannedSeconds, 25 * 60);
      expect(state.remainingSeconds, 25 * 60);
      expect(state.status, TimerStatus.idle);
      expect(state.progress, 0);
    });

    test('start changes status to running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(focusTimerProvider.notifier).start();

      final state = container.read(focusTimerProvider);

      expect(state.status, TimerStatus.running);
    });

    test('pause changes running timer to paused', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(focusTimerProvider.notifier);

      notifier.start();
      notifier.pause();

      final state = container.read(focusTimerProvider);

      expect(state.status, TimerStatus.paused);
    });

    test('resume changes paused timer back to running', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(focusTimerProvider.notifier);

      notifier.start();
      notifier.pause();
      notifier.resume();

      final state = container.read(focusTimerProvider);

      expect(state.status, TimerStatus.running);
    });

    test('finish changes active timer to finished', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(focusTimerProvider.notifier);

      notifier.start();
      notifier.finish();

      final state = container.read(focusTimerProvider);

      expect(state.status, TimerStatus.finished);
    });

    test('finish does nothing while timer is idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(focusTimerProvider.notifier).finish();

      final state = container.read(focusTimerProvider);

      expect(state.status, TimerStatus.idle);
    });

    test('reset restores planned duration and idle state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(focusTimerProvider.notifier);

      notifier.start();
      notifier.pause();
      notifier.reset();

      final state = container.read(focusTimerProvider);

      expect(state.remainingSeconds, state.plannedSeconds);
      expect(state.status, TimerStatus.idle);
      expect(state.progress, 0);
    });

    test('hasStarted is false initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(focusTimerProvider);

      expect(state.hasStarted, false);
    });

    test('hasStarted becomes true after timer starts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(focusTimerProvider.notifier).start();

      final state = container.read(focusTimerProvider);

      expect(state.hasStarted, true);
    });
  });
}