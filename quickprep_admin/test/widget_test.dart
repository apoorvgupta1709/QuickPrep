import 'package:flutter_test/flutter_test.dart';
import 'package:quickprep_admin/main.dart';

void main() {
  testWidgets('QuickPrep Admin smoke test loads dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickPrepAdminApp());
    expect(find.byType(QuickPrepAdminApp), findsOneWidget);
  });
}
