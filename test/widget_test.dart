import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/main.dart';

void main() {
  testWidgets('Dashboard loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    // Verify the dashboard heading.
    expect(find.text('Your Focus Dashboard'), findsOneWidget);

    // Verify the main navigation buttons.
    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('History & Insights'), findsOneWidget);

    // Verify important dashboard sections.
    expect(find.text('Session Scout'), findsOneWidget);
    expect(find.text('Your Presets'), findsOneWidget);
  });
}
