import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/shift.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';
import 'package:flutter_pos_desktop/screens/pos_screen.dart';
import 'package:flutter_pos_desktop/screens/system_screen.dart';

void main() {
  group('POSScreen access gating', () {
    late AppDatabase database;
    late PosProvider provider;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      provider = PosProvider(repository: PosRepository(database));
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('shows System Info when business day and shift are not open', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: POSScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('System Info'), findsOneWidget);
      expect(find.text('Open Business Day'), findsOneWidget);
    });

    testWidgets('System Info adapts to a narrow screen without overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: POSScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Point of sale setup'), findsOneWidget);
      expect(find.text('Business day'), findsOneWidget);
      expect(find.text('Current shift'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('business day and current shift boxes have matching heights', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      final user = AppUser(
        id: '1001',
        name: 'Alex Chen',
        role: 'Cashier',
        loginTime: DateTime.now(),
      );
      provider.setUser(user);
      await provider.openBusinessDay(user);
      await provider.openShift(ShiftType.breakfast, user);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: SystemScreen()),
        ),
      );
      await tester.pump();

      final dayRect = tester.getRect(
        find.byKey(const ValueKey('business-day-card')),
      );
      final shiftRect = tester.getRect(
        find.byKey(const ValueKey('current-shift-card')),
      );
      expect(dayRect.top, shiftRect.top);
      expect(dayRect.height, shiftRect.height);
      final dayActionRect = tester.getRect(
        find.byKey(const ValueKey('business-day-action')),
      );
      final shiftActionRect = tester.getRect(
        find.byKey(const ValueKey('current-shift-action')),
      );
      expect(dayActionRect.bottom, shiftActionRect.bottom);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows POS layout after business day and shift are opened', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      final user = AppUser(
        id: '1001',
        name: 'Alex Chen',
        role: 'Cashier',
        loginTime: DateTime.now(),
      );
      provider.setUser(user);
      await provider.openBusinessDay(user);
      await provider.openShift(ShiftType.breakfast, user);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: POSScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('System Info'), findsNothing);
      expect(find.text('FlutterPOS'), findsOneWidget);
    });
  });
}
