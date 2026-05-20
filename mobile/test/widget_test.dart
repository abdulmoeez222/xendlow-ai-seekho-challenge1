import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insight_engine/main.dart';

void main() {
  testWidgets('App compiles and launches to a blank home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InsightEngineApp(isLoggedIn: true));

    // Verify that the Scaffold and SizedBox (our blank screen) are present
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
