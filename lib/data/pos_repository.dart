import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color;
import '../models/business_day.dart';
import '../models/shift.dart';
import '../models/suspended_order.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'app_database.dart';

class PosRepository {
  final AppDatabase _db;

  PosRepository(this._db);

  // ── Business Day ─────────────────────────────────────────────────────────────

  Future<BusinessDay?> loadActiveBusinessDay() async {
    final row = await (_db.select(_db.businessDays)
          ..where((t) => t.closedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toBusinessDay(row);
  }

  Future<void> saveBusinessDay(BusinessDay bd) async {
    await _db.into(_db.businessDays).insertOnConflictUpdate(
          BusinessDaysCompanion(
            id: Value(bd.id),
            openedAt: Value(bd.openedAt),
            closedAt: Value(bd.closedAt),
            openedByName: Value(bd.openedByName),
            openedById: Value(bd.openedById),
            closedByName: Value(bd.closedByName),
            closedById: Value(bd.closedById),
          ),
        );
  }

  // ── Shifts ───────────────────────────────────────────────────────────────────

  Future<List<Shift>> loadShiftsForDay(String businessDayId) async {
    final rows = await (_db.select(_db.shifts)
          ..where((t) => t.businessDayId.equals(businessDayId))
          ..orderBy([(t) => OrderingTerm.asc(t.openedAt)]))
        .get();
    return rows.map(_toShift).toList();
  }

  Future<void> saveShift(Shift shift) async {
    await _db.into(_db.shifts).insertOnConflictUpdate(
          ShiftsCompanion(
            id: Value(shift.id),
            businessDayId: Value(shift.businessDayId),
            type: Value(shift.type.name),
            openedAt: Value(shift.openedAt),
            closedAt: Value(shift.closedAt),
            openedByName: Value(shift.openedByName),
            openedById: Value(shift.openedById),
            closedByName: Value(shift.closedByName),
            closedById: Value(shift.closedById),
          ),
        );
  }

  // ── Suspended Orders ───────────────────────────────────────────────────────────

  Future<List<SuspendedOrder>> loadSuspendedOrdersForShift(String shiftId) async {
    final rows = await (_db.select(_db.suspendedOrders)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    final result = <SuspendedOrder>[];
    for (final row in rows) {
      final itemRows = await (_db.select(_db.suspendedOrderItems)
            ..where((i) => i.suspendedOrderId.equals(row.id)))
          .get();
      result.add(_toSuspendedOrder(row, itemRows));
    }
    return result;
  }

  Future<void> saveSuspendedOrder(SuspendedOrder order) async {
    await _db.transaction(() async {
      await _db.into(_db.suspendedOrders).insertOnConflictUpdate(
            SuspendedOrdersCompanion(
              id: Value(order.id),
              shiftId: Value(order.shiftId),
              orderLabel: Value(order.orderLabel),
              cashierId: Value(order.cashierId),
              cashierName: Value(order.cashierName),
              createdAt: Value(order.createdAt),
              updatedAt: Value(order.updatedAt),
            ),
          );
      await (_db.delete(_db.suspendedOrderItems)
            ..where((t) => t.suspendedOrderId.equals(order.id)))
          .go();
      for (final item in order.items) {
        await _db.into(_db.suspendedOrderItems).insert(
              SuspendedOrderItemsCompanion.insert(
                suspendedOrderId: order.id,
                productId: item.product.id,
                productName: item.product.name,
                productPrice: item.product.price,
                productCategory: item.product.category,
                productEmoji: item.product.emoji,
                productColor: item.product.color.toARGB32(),
                quantity: item.quantity,
              ),
            );
      }
    });
  }

  Future<void> deleteSuspendedOrder(String orderId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.suspendedOrderItems)
            ..where((t) => t.suspendedOrderId.equals(orderId)))
          .go();
      await (_db.delete(_db.suspendedOrders)..where((t) => t.id.equals(orderId)))
          .go();
    });
  }

  // ── Transactions ──────────────────────────────────────────────────────────────

  Future<List<Transaction>> loadTransactionsForShift(String shiftId) async {
    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();

    final result = <Transaction>[];
    for (final row in rows) {
      final itemRows = await (_db.select(_db.cartItems)
            ..where((i) => i.transactionId.equals(row.id)))
          .get();
      result.add(_toTransaction(row, itemRows));
    }
    return result;
  }

  Future<void> insertTransaction(Transaction txn) async {
    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              id: txn.id,
              shiftId: txn.shiftId ?? '',
              cashierId: Value(txn.cashierId),
              cashierName: Value(txn.cashierName),
              subtotal: txn.subtotal,
              tax: txn.tax,
              total: txn.total,
              tenderType: txn.tenderType.name,
              cashAmount: txn.cashAmount,
              cardAmount: txn.cardAmount,
              changeAmount: txn.change,
              timestamp: txn.timestamp,
            ),
          );
      for (final item in txn.items) {
        await _db.into(_db.cartItems).insert(
              CartItemsCompanion.insert(
                transactionId: txn.id,
                productId: item.product.id,
                productName: item.product.name,
                productPrice: item.product.price,
                productCategory: item.product.category,
                productEmoji: item.product.emoji,
                productColor: item.product.color.toARGB32(),
                quantity: item.quantity,
              ),
            );
      }
    });
  }

  Future<void> updateTransactionVoid(Transaction txn) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.id.equals(txn.id)))
        .write(TransactionsCompanion(
      isVoided: const Value(true),
      voidedByName: Value(txn.voidedByName),
      voidedById: Value(txn.voidedById),
      voidedAt: Value(txn.voidedAt),
    ));
  }

  // ── Domain mappers ────────────────────────────────────────────────────────────

  BusinessDay _toBusinessDay(BusinessDayRow r) => BusinessDay(
        id: r.id,
        openedAt: r.openedAt,
        closedAt: r.closedAt,
        openedByName: r.openedByName,
        openedById: r.openedById,
        closedByName: r.closedByName,
        closedById: r.closedById,
      );

  Shift _toShift(ShiftRow r) => Shift(
        id: r.id,
        businessDayId: r.businessDayId,
        type: ShiftType.values.byName(r.type),
        openedAt: r.openedAt,
        closedAt: r.closedAt,
        openedByName: r.openedByName,
        openedById: r.openedById,
        closedByName: r.closedByName,
        closedById: r.closedById,
      );

  Transaction _toTransaction(TransactionRow r, List<CartItemRow> itemRows) {
    final items = itemRows
        .map((i) => CartItem(
              product: Product(
                id: i.productId,
                name: i.productName,
                price: i.productPrice,
                category: i.productCategory,
                emoji: i.productEmoji,
                color: Color(i.productColor),
              ),
              quantity: i.quantity,
            ))
        .toList();

    return Transaction(
      id: r.id,
      items: items,
      subtotal: r.subtotal,
      tax: r.tax,
      total: r.total,
      tenderType: TenderType.values.byName(r.tenderType),
      cashAmount: r.cashAmount,
      cardAmount: r.cardAmount,
      change: r.changeAmount,
      timestamp: r.timestamp,
      isVoided: r.isVoided,
      voidedByName: r.voidedByName,
      voidedById: r.voidedById,
      voidedAt: r.voidedAt,
      shiftId: r.shiftId,
      cashierId: r.cashierId,
      cashierName: r.cashierName,
    );
  }

  SuspendedOrder _toSuspendedOrder(
    SuspendedOrderRow row,
    List<SuspendedOrderItemRow> itemRows,
  ) {
    final items = itemRows
        .map(
          (i) => CartItem(
            product: Product(
              id: i.productId,
              name: i.productName,
              price: i.productPrice,
              category: i.productCategory,
              emoji: i.productEmoji,
              color: Color(i.productColor),
            ),
            quantity: i.quantity,
          ),
        )
        .toList();

    return SuspendedOrder(
      id: row.id,
      shiftId: row.shiftId,
      orderLabel: row.orderLabel,
      items: items,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      cashierId: row.cashierId,
      cashierName: row.cashierName,
    );
  }
}
