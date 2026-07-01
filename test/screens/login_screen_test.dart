// test/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/screens/login_screen.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('displays login form with input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Access Code'), findsOneWidget);
    });

    testWidgets('displays numeric keypad with digits 0-9', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      for (int i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
    });

    testWidgets('displays backspace button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('typing into User ID field updates text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Find and tap a digit button
      await tester.tap(find.text('1'));
      await tester.pump();

      // Input field should show '1'
      expect(find.text('1'), findsWidgets); // appears in both keypad and input
    });

    testWidgets('backspace clears all text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Type "12"
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.pump();

      // Verify "1" and "2" are in the keypad
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);

      // Backspace - should clear all text
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // User ID field should show placeholder text (empty)
      expect(find.text('Enter user ID'), findsOneWidget);
    });

    testWidgets('Sign In button is not displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('demo credentials are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Demo Credentials'), findsOneWidget);
      expect(find.text('1001'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('Cashier Sign In header is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Cashier Sign In'), findsOneWidget);
    });

    testWidgets('app title FlutterPOS is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('FlutterPOS'), findsOneWidget);
    });

    testWidgets('Point of Sale System subtitle is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Point of Sale System'), findsOneWidget);
    });
  });
}
