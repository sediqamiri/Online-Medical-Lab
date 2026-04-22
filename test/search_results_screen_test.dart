import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_medicine_lab/screens/dashboard/search_results_screen.dart';

void main() {
  Widget buildSubject({required String testName}) {
    return MaterialApp(
      home: SearchResultsScreen(testName: testName),
    );
  }

  testWidgets('shows only labs that support the searched test',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(testName: 'Blood Sugar'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Zuhal Diagnostic'),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Recommended labs'), findsOneWidget);
    expect(find.text('City Medical Lab'), findsWidgets);
    expect(find.text('Zuhal Diagnostic'), findsOneWidget);
    expect(find.text('Shahr-e-Naw'), findsNothing);
    expect(find.text('Wazir Akbar Khan'), findsNothing);
  });

  testWidgets('shows a recovery path when no labs match the query',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(testName: 'X-Ray'));

    expect(find.text('No exact matches yet for X-Ray.'), findsOneWidget);
    expect(find.text('Try a popular search'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Full Blood Count'),
        findsOneWidget);
    expect(find.text('City Medical Lab'), findsNothing);
  });
}
