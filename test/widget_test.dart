import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:estimation_tool/main.dart';

void main() {
  testWidgets('Create session page renders one input and two actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Session'), findsOneWidget);
    expect(find.text('Session ID'), findsOneWidget);
    expect(find.text('Join existing session'), findsOneWidget);
    expect(find.text('Create session'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Join existing session routes to session screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'abc-123');
    await tester.tap(find.text('Join existing session'));
    await tester.pumpAndSettle();

    expect(find.text('Session'), findsOneWidget);
    expect(find.text('Session ID: abc-123'), findsOneWidget);
  });

  testWidgets('Create session routes to generated session when input is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create session'));
    await tester.pumpAndSettle();

    expect(find.text('Session'), findsOneWidget);
    expect(find.textContaining('Session ID: '), findsOneWidget);
  });
}
