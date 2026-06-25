import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayther/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build the app and verify it pumps without throwing
    await tester.pumpWidget(const WaytherApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
