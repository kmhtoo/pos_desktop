import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Table definitions ─────────────────────────────────────────────────────────

@DataClassName('BusinessDayRow')
class BusinessDays extends Table {
  @override
  String get tableName => 'business_days';

  TextColumn get id => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get openedByName => text()();
  TextColumn get openedById => text()();
  TextColumn get closedByName => text().nullable()();
  TextColumn get closedById => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShiftRow')
class Shifts extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get id => text()();
  TextColumn get businessDayId => text()();
  TextColumn get type => text()(); // 'breakfast' | 'lunch' | 'dinner'
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get openedByName => text()();
  TextColumn get openedById => text()();
  TextColumn get closedByName => text().nullable()();
  TextColumn get closedById => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();
  TextColumn get shiftId => text()();
  TextColumn get cashierId => text().nullable()();
  TextColumn get cashierName => text().nullable()();
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get total => real()();
  TextColumn get tenderType => text()(); // 'cash' | 'card' | 'split'
  RealColumn get cashAmount => real()();
  RealColumn get cardAmount => real()();
  RealColumn get changeAmount => real()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isVoided =>
      boolean().withDefault(const Constant(false))();
  TextColumn get voidedByName => text().nullable()();
  TextColumn get voidedById => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CartItemRow')
class CartItems extends Table {
  @override
  String get tableName => 'cart_items';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get productPrice => real()();
  TextColumn get productCategory => text()();
  TextColumn get productEmoji => text()();
  IntColumn get productColor => integer()(); // Color.value (ARGB int)
  IntColumn get quantity => integer()();
}

// ── Database class ────────────────────────────────────────────────────────────

@DriftDatabase(tables: [BusinessDays, Shifts, Transactions, CartItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dir.path, 'flutter_pos'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    final file = File(p.join(dbDir.path, 'pos.db'));
    return NativeDatabase(file);
  });
}
