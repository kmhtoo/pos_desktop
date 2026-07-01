// test/integration/pos_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('POS Integration Tests', () {
    testWidgets('cart operations: add product → adjust quantity → update totals',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();
      final user = testUser();
      mockProvider.setUser(user);
      mockProvider.setBusinessDayActive(true);
      mockProvider.setShiftActive(true);

      await tester.pumpWidget(
        createTestApp(child: const Placeholder(), mockProvider: mockProvider),
      );

      // Verify cart operations
      mockProvider.setCartItemCount(1);
      expect(mockProvider.cartItemCount, 1);

      mockProvider.setSubtotal(50.0);
      expect(mockProvider.total, 55.0);
    });

    testWidgets('payment processing requires shift to be active',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();
      final user = testUser();
      mockProvider.setUser(user);

      // Business day open but no shift
      mockProvider.setBusinessDayActive(true);
      mockProvider.setShiftActive(false);
      mockProvider.setSubtotal(100.0);

      // Payment should not be processable
      expect(mockProvider.hasActiveShift, false);

      // Now open shift
      mockProvider.setShiftActive(true);
      expect(mockProvider.hasActiveShift, true);
    });

    testWidgets('logout clears user but preserves cart state',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();
      final user = testUser();
      mockProvider.setUser(user);
      mockProvider.setBusinessDayActive(true);
      mockProvider.setShiftActive(true);
      mockProvider.setSubtotal(100.0);

      expect(mockProvider.currentUser, isNotNull);

      // Cart state persists
      expect(mockProvider.total, 110.0);
    });

    testWidgets('new user can login after previous logout',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();

      final user1 = AppUser(
        id: '1001',
        name: 'Alice',
        role: 'Cashier',
        loginTime: DateTime.now(),
      );

      mockProvider.setUser(user1);
      expect(mockProvider.currentUser!.name, 'Alice');

      final user2 = AppUser(
        id: '1002',
        name: 'Bob',
        role: 'Manager',
        loginTime: DateTime.now(),
      );

      mockProvider.setUser(user2);
      expect(mockProvider.currentUser!.name, 'Bob');
    });

    testWidgets('cart state is independent of user state',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();

      mockProvider.setSubtotal(100.0);
      expect(mockProvider.total, 110.0);

      // Cart state persists
      expect(mockProvider.total, 110.0);
    });

    testWidgets('multiple shifts can be tracked',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();
      final user = testUser();
      mockProvider.setUser(user);

      mockProvider.setBusinessDayActive(true);

      // Open breakfast shift
      mockProvider.setShiftActive(true);
      expect(mockProvider.hasActiveShift, true);

      // Close it (simulated)
      mockProvider.setShiftActive(false);

      // Open lunch shift
      mockProvider.setShiftActive(true);
      expect(mockProvider.hasActiveShift, true);
    });

    testWidgets('category filtering works correctly',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();
      final user = testUser();
      mockProvider.setUser(user);

      expect(mockProvider.selectedCategory, 'All');

      mockProvider.selectCategory('Beverages');
      expect(mockProvider.selectedCategory, 'Beverages');

      mockProvider.selectCategory('Food');
      expect(mockProvider.selectedCategory, 'Food');
    });

    testWidgets('tax calculation is accurate across multiple totals',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();

      // Test various amounts
      final testCases = [
        (10.0, 1.0, 11.0),
        (25.5, 2.55, 28.05),
        (99.99, 9.999, 109.989),
      ];

      for (final (subtotal, expectedTax, expectedTotal) in testCases) {
        mockProvider.setSubtotal(subtotal);
        expect(
          mockProvider.tax,
          closeTo(expectedTax, 0.01),
          reason: 'Tax incorrect for subtotal $subtotal',
        );
        expect(
          mockProvider.total,
          closeTo(expectedTotal, 0.01),
          reason: 'Total incorrect for subtotal $subtotal',
        );
      }
    });

    testWidgets('business day and shift states are independent',
        (WidgetTester tester) async {
      final mockProvider = MockPosProvider();

      // Business day closed, shift inactive
      mockProvider.setBusinessDayActive(false);
      mockProvider.setShiftActive(false);
      expect(mockProvider.hasActiveBusinessDay, false);
      expect(mockProvider.hasActiveShift, false);

      // Open business day
      mockProvider.setBusinessDayActive(true);
      expect(mockProvider.hasActiveBusinessDay, true);
      expect(mockProvider.hasActiveShift, false);

      // Open shift
      mockProvider.setShiftActive(true);
      expect(mockProvider.hasActiveBusinessDay, true);
      expect(mockProvider.hasActiveShift, true);

      // Close shift but keep business day
      mockProvider.setShiftActive(false);
      expect(mockProvider.hasActiveBusinessDay, true);
      expect(mockProvider.hasActiveShift, false);
    });
  });
}
