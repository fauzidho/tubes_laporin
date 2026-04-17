import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tubes_apb/main.dart';

void main() {
  testWidgets('LaporIn app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LaporInApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
