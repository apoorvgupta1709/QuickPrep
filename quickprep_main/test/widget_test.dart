import 'package:flutter_test/flutter_test.dart';
import 'package:quickprep/main.dart';

void main() {
  testWidgets('QuickPrep smoke test loads app and transitions to onboarding or home', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickPrepApp());
    expect(find.byType(QuickPrepApp), findsOneWidget);

    // Let the splash animation and navigation timer settle
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Personalize Your Prep'), findsOneWidget);
  });
}
