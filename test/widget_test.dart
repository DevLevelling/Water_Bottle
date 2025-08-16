// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:water_bottle/main.dart';

void main() {
  testWidgets('Intro page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WaterBottleApp());

    // Verify that our intro page displays the correct title.
    expect(find.text('Track your water fetching'), findsOneWidget);

    // Verify that the description text is displayed.
    expect(
      find.text(
        'Post your water fetch actions, verify others\' posts, and earn points on the leaderboard.',
      ),
      findsOneWidget,
    );

    // Verify that both buttons are displayed.
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
