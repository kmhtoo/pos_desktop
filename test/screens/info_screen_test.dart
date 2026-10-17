import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/shift.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';
import 'package:flutter_pos_desktop/screens/info_screen.dart';
import 'package:flutter_pos_desktop/services/receipt_printer.dart';

class _FakeReceiptPrinter implements ReceiptPrinter {
  final printedTransactions = <Transaction>[];

  @override
  Future<void> printReceipt(Transaction transaction) async {
    printedTransactions.add(transaction);
  }
}

void main() {
  testWidgets('reprints voided receipts from receipt history', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final printer = _FakeReceiptPrinter();
    final provider = PosProvider(
      repository: PosRepository(database),
      receiptPrinter: printer,
    );
    final user = AppUser(
      id: '1001',
      name: 'Alex Chen',
      role: 'Cashier',
      loginTime: DateTime.now(),
    );
    provider.setUser(user);
    await provider.openBusinessDay(user);
    await provider.openShift(ShiftType.breakfast, user);
    provider.addToCart(provider.products.first);
    final transaction = await provider.processPayment(
      tenderType: TenderType.cash,
      cashAmount: provider.total,
      cardAmount: 0,
    );
    await provider.voidTransaction(transaction.id);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: InfoScreen()),
      ),
    );
    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();

    expect(find.text('Print VOID'), findsOneWidget);
    await tester.tap(find.text('Print VOID'));
    await tester.pumpAndSettle();

    expect(printer.printedTransactions, hasLength(2));
    expect(printer.printedTransactions.last.isVoided, isTrue);
    expect(find.text('VOID receipt sent to printer.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
    await tester.binding.setSurfaceSize(null);
  });
}
