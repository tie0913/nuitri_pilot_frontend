import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nuitri_pilot_frontend/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    // Build the real app and trigger the first frame.
    await tester.pumpWidget(const NutriPilot());

    // Let async initialization + routing settle.
    await tester.pumpAndSettle();

    // Smoke assertion: app built a widget tree that includes MaterialApp.
    // Using findsWidgets (not findsOneWidget) because your app may wrap or rebuild.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}