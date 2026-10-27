import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/widgets/session_scout_card.dart';

void main() {
  group('SessionScoutCard', () {
    testWidgets(
      'shows not enough history when suggestion is null',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SessionScoutCard(
                suggestedMinutes: null,
              ),
            ),
          ),
        );

        expect(find.text('Session Scout'), findsOneWidget);
        expect(find.text('Not enough history'), findsOneWidget);
        expect(find.text('Apply'), findsNothing);
      },
    );

    testWidgets(
      'shows suggested duration when suggestion exists',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SessionScoutCard(
                suggestedMinutes: 25,
                onApply: () {},
              ),
            ),
          ),
        );

        expect(find.text('Session Scout'), findsOneWidget);
        expect(
          find.text('Suggested duration: 25 minutes'),
          findsOneWidget,
        );
        expect(find.text('Apply'), findsOneWidget);
      },
    );

    testWidgets(
      'calls onApply when Apply button is pressed',
      (tester) async {
        var applyPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SessionScoutCard(
                suggestedMinutes: 30,
                onApply: () {
                  applyPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Apply'));
        await tester.pump();

        expect(applyPressed, isTrue);
      },
    );
  });
}