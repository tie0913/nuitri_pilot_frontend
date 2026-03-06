import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nuitri_pilot_frontend/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches end-to-end', (tester) async {
    await tester.pumpWidget(const NutriPilot());

    // Avoid pumpAndSettle hangs when startup has ongoing animations.
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(NutriPilot), findsOneWidget);
  });
}
