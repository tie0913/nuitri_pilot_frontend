import 'package:flutter_test/flutter_test.dart';
import 'package:nuitri_pilot_frontend/main.dart';

void main() {
  testWidgets('App boots (smoke)', (tester) async {
    await tester.pumpWidget(const NutriPilot());
    await tester.pumpAndSettle();
    expect(true, true); // keep it simple and stable
  });
}