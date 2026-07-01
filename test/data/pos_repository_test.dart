// test/data/pos_repository_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/business_day.dart';
import 'package:flutter_pos_desktop/models/shift.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/models/cart_item.dart';
import 'package:flutter_pos_desktop/models/product.dart';

void main() {
  group('PosRepository Tests', () {
    late AppDatabase database;
    late PosRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = PosRepository(database);
    });

    test('saveBusinessDay persists a business day', () async {
      final now = DateTime.now();
      final bd = BusinessDay(
        id: 'BD-20240101',
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );

      await repository.saveBusinessDay(bd);

      final loaded = await repository.loadActiveBusinessDay();
      expect(loaded, isNotNull);
      expect(loaded!.id, 'BD-20240101');
    });

    test('loadActiveBusinessDay returns null when none exist', () async {
      final loaded = await repository.loadActiveBusinessDay();
      expect(loaded, isNull);
    });

    test('saveShift persists a shift', () async {
      final now = DateTime.now();
      final shift = Shift(
        id: 'SHF-1',
        businessDayId: 'BD-20240101',
        type: ShiftType.breakfast,
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );

      await repository.saveShift(shift);

      final shifts = await repository.loadShiftsForDay('BD-20240101');
      expect(shifts, isNotEmpty);
      expect(shifts.first.id, 'SHF-1');
    });

    test('loadShiftsForDay returns empty list when none exist', () async {
      final shifts = await repository.loadShiftsForDay('BD-nonexistent');
      expect(shifts, isEmpty);
    });

    test('insertTransaction persists a transaction', () async {
      final product = const Product(
        id: 'prod1',
        name: 'Coffee',
        price: 3.50,
        category: 'Beverages',
        color: Color(0xFF8B4513),
        emoji: '☕',
      );

      final txn = Transaction(
        id: 'TXN-1',
        items: [CartItem(product: product, quantity: 1)],
        subtotal: 3.50,
        tax: 0.35,
        total: 3.85,
        tenderType: TenderType.cash,
        cashAmount: 5.0,
        cardAmount: 0,
        change: 1.15,
        timestamp: DateTime.now(),
        shiftId: 'SHF-1',
        cashierId: 'user1',
        cashierName: 'John',
      );

      await repository.insertTransaction(txn);

      final loaded = await repository.loadTransactionsForShift('SHF-1');
      expect(loaded, isNotEmpty);
      expect(loaded.first.id, 'TXN-1');
    });

    test('loadTransactionsForShift returns empty list when none exist', () async {
      final txns = await repository.loadTransactionsForShift('SHF-nonexistent');
      expect(txns, isEmpty);
    });

    test('updateTransactionVoid marks transaction as voided', () async {
      final product = const Product(
        id: 'prod1',
        name: 'Coffee',
        price: 3.50,
        category: 'Beverages',
        color: Color(0xFF8B4513),
        emoji: '☕',
      );

      final txn = Transaction(
        id: 'TXN-1',
        items: [CartItem(product: product, quantity: 1)],
        subtotal: 3.50,
        tax: 0.35,
        total: 3.85,
        tenderType: TenderType.cash,
        cashAmount: 5.0,
        cardAmount: 0,
        change: 1.15,
        timestamp: DateTime.now(),
        shiftId: 'SHF-1',
        cashierId: 'user1',
        cashierName: 'John',
      );

      await repository.insertTransaction(txn);

      final voidedTxn = txn.voidWith(
        voidedByName: 'John',
        voidedById: 'user1',
      );

      await repository.updateTransactionVoid(voidedTxn);

      final loaded = await repository.loadTransactionsForShift('SHF-1');
      expect(loaded.first.isVoided, true);
    });

    test('database persists data across multiple operations', () async {
      final now = DateTime.now();

      // Create and save business day
      final bd = BusinessDay(
        id: 'BD-20240101',
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );
      await repository.saveBusinessDay(bd);

      // Create and save shift
      final shift = Shift(
        id: 'SHF-1',
        businessDayId: 'BD-20240101',
        type: ShiftType.breakfast,
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );
      await repository.saveShift(shift);

      // Verify both exist
      final loadedBd = await repository.loadActiveBusinessDay();
      final loadedShifts = await repository.loadShiftsForDay('BD-20240101');

      expect(loadedBd, isNotNull);
      expect(loadedShifts, isNotEmpty);
    });

    test('shift can be closed', () async {
      final now = DateTime.now();
      final shift = Shift(
        id: 'SHF-1',
        businessDayId: 'BD-20240101',
        type: ShiftType.breakfast,
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );

      await repository.saveShift(shift);

      final closedShift = shift.close(closedByName: 'John', closedById: 'user1');
      await repository.saveShift(closedShift);

      final loaded = await repository.loadShiftsForDay('BD-20240101');
      expect(loaded.first.isOpen, false);
    });

    test('business day can be closed', () async {
      final now = DateTime.now();
      final bd = BusinessDay(
        id: 'BD-20240101',
        openedAt: now,
        closedAt: null,
        openedByName: 'John',
        openedById: 'user1',
        closedByName: null,
        closedById: null,
      );

      await repository.saveBusinessDay(bd);

      final closedBd = bd.close(closedByName: 'John', closedById: 'user1');
      await repository.saveBusinessDay(closedBd);

      final loaded = await repository.loadActiveBusinessDay();
      expect(loaded, isNull); // Closed business day is not active
    });
  });
}
