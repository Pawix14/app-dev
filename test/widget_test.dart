import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finallanggo/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const FilipinoLearningApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
