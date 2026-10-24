import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/main.dart';

void main() {
  testWidgets('Dashboard loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    // Content visible at the top of the Dashboard.
    expect(find.text('Your Focus Dashboard'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('Mood Filter'), findsOneWidget);
    expect(find.text('Session Scout'), findsOneWidget);

    // Scroll until the lower Dashboard actions are visible.
    await tester.scrollUntilVisible(
      find.text('Create Preset'),
      300,
    );

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('History & Insights'), findsOneWidget);
  });
}