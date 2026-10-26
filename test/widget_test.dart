import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/main.dart';

void main() {
  testWidgets('Dashboard loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    expect(find.text('Your Focus Dashboard'), findsOneWidget);
    expect(find.text('Session Scout'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Create Preset'),
      300,
    );

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('History & Insights'), findsOneWidget);
  });
}