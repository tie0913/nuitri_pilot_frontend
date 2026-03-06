import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nuitri_pilot_frontend/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches end-to-end', (tester) async {
    await tester.pumpWidget(const NutriPilot());
    await tester.pumpAndSettle();

    // If app crashes at startup, this test will fail — that’s the point.
    expect(true, true);
  });
}