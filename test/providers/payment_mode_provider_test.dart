import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/shift.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';
import 'package:flutter_pos_desktop/services/receipt_printer.dart';

class _FakeReceiptPrinter implements ReceiptPrinter {
  final List<Transaction> printedTransactions = [];

  @override
  Future<void> printReceipt(Transaction transaction) async {
    printedTransactions.add(transaction);
  }
}

class _FailingReceiptPrinter implements ReceiptPrinter {
  @override
  Future<void> printReceipt(Transaction transaction) async {
    throw Exception('Printer offline');
  }
}

class _FakePrinterDriver implements PrinterDriver {
  final List<PrinterDevice> sentDevices = [];
  final List<List<int>> sentBytes = [];

  @override
  bool canHandle(PrinterDevice device) => true;

  @override
  Future<void> sendBytes(PrinterDevice device, List<int> bytes) async {
    sentDevices.add(device);
    sentBytes.add(bytes);
  }

  @override
  Future<void> testConnection(PrinterDevice device) async {
    sentDevices.add(device);
  }
}

void main() {
  group('Payment mode provider state', () {
    late AppDatabase database;
    late PosProvider provider;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      provider = PosProvider(repository: PosRepository(database));
    });

    test('defaults to cash and exposes supported modes including voucher', () {
      expect(provider.selectedPaymentMode, TenderType.cash);
      expect(provider.paymentModes, isNot(contains(TenderType.split)));
      expect(provider.paymentModes, contains(TenderType.voucher));
    });

    test('selectPaymentMode updates selected mode', () {
      provider.selectPaymentMode(TenderType.voucher);
      expect(provider.selectedPaymentMode, TenderType.voucher);
      expect(provider.showPaymentHistory, isFalse);
    });

    test('history view toggles and resets when selecting payment mode', () {
      provider.showPaymentHistoryView();
      expect(provider.showPaymentHistory, isTrue);

      provider.selectPaymentMode(TenderType.card);
      expect(provider.selectedPaymentMode, TenderType.card);
      expect(provider.showPaymentHistory, isFalse);
    });

    test('cash denomination drafts accumulate into tender lines', () {
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(5.0);

      expect(provider.cashTenderedDraft, 25.0);
      expect(provider.cashTenderCountFor(10.0), 2);
      expect(provider.cashTenderCountFor(5.0), 1);
      expect(provider.cashTenderLinesDraft.length, 2);
      expect(provider.cashTenderLinesDraft.first.key, 10.0);
      expect(provider.cashTenderLinesDraft.first.value, 2);

      provider.clearPaymentDrafts();
      expect(provider.cashTenderedDraft, 0.0);
      expect(provider.cashTenderLinesDraft, isEmpty);
    });

    test('removeCashDenominationDraft decrements one tender unit', () {
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(5.0);

      provider.removeCashDenominationDraft(10.0);
      expect(provider.cashTenderedDraft, 15.0);
      expect(provider.cashTenderCountFor(10.0), 1);

      provider.removeCashDenominationDraft(10.0);
      expect(provider.cashTenderedDraft, 5.0);
      expect(provider.cashTenderCountFor(10.0), 0);
      expect(provider.cashTenderLinesDraft.map((e) => e.key), [5.0]);
    });

    test('cash denomination visibility and enabled settings can be updated', () {
      expect(provider.isCashDenominationVisible(10000.0), isTrue);
      expect(provider.isCashDenominationEnabled(10000.0), isTrue);

      provider.setCashDenominationVisibility(10000.0, false);
      provider.setCashDenominationEnabled(10000.0, false);

      expect(provider.isCashDenominationVisible(10000.0), isFalse);
      expect(provider.isCashDenominationEnabled(10000.0), isFalse);
      expect(provider.visibleCashDenominations, isNot(contains(10000.0)));
    });

    test('can park and resume an unfinished order with custom label', () async {
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
      provider.addToCart(provider.products[1]);

      final parked = await provider.parkCurrentOrder(customLabel: 'Table 3');

      expect(parked, isNotNull);
      expect(parked!.orderLabel, 'Table 3');
      expect(provider.cart, isEmpty);
      expect(provider.suspendedOrders, hasLength(1));

      final resumed = await provider.resumeSuspendedOrder(parked.id);

      expect(resumed, isTrue);
      expect(provider.suspendedOrders, isEmpty);
      expect(provider.cart, hasLength(2));
      expect(provider.cartItemCount, 2);
    });

    test('parked order uses auto-number label when cashier leaves name blank', () async {
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

      final firstParked = await provider.parkCurrentOrder();
      expect(firstParked?.orderLabel, 'Saved Order #1');

      provider.addToCart(provider.products.first);
      final secondParked = await provider.parkCurrentOrder(customLabel: '   ');
      expect(secondParked?.orderLabel, 'Saved Order #2');
    });

    test('suspended orders persist across provider reload', () async {
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

      final parked = await provider.parkCurrentOrder();
      expect(parked, isNotNull);

      final reloaded = PosProvider(repository: PosRepository(database));
      await reloaded.init();

      expect(reloaded.suspendedOrders, hasLength(1));
      expect(reloaded.suspendedOrders.single.itemCount, 1);
      expect(reloaded.suspendedOrders.single.orderLabel, 'Saved Order #1');
    });

    test('cannot close shift while suspended orders remain', () async {
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
      await provider.parkCurrentOrder();

      await provider.closeShift(user);

      expect(provider.hasActiveShift, isTrue);
      expect(provider.currentShift?.isOpen, isTrue);
    });

    test('processPayment sends transaction to receipt printer', () async {
      final printer = _FakeReceiptPrinter();
      final providerWithPrinter = PosProvider(
        repository: PosRepository(database),
        receiptPrinter: printer,
      );
      final user = AppUser(
        id: '1001',
        name: 'Alex Chen',
        role: 'Cashier',
        loginTime: DateTime.now(),
      );
      providerWithPrinter.setUser(user);
      await providerWithPrinter.openBusinessDay(user);
      await providerWithPrinter.openShift(ShiftType.breakfast, user);
      providerWithPrinter.addToCart(providerWithPrinter.products.first);

      final txn = await providerWithPrinter.processPayment(
        tenderType: TenderType.cash,
        cashAmount: providerWithPrinter.total,
        cardAmount: 0.0,
      );

      expect(printer.printedTransactions.length, 1);
      expect(printer.printedTransactions.first.id, txn.id);
    });

    test(
      'processPayment still settles order when receipt printing fails',
      () async {
        final providerWithPrinterFailure = PosProvider(
          repository: PosRepository(database),
          receiptPrinter: _FailingReceiptPrinter(),
        );
        final user = AppUser(
          id: '1001',
          name: 'Alex Chen',
          role: 'Cashier',
          loginTime: DateTime.now(),
        );
        providerWithPrinterFailure.setUser(user);
        await providerWithPrinterFailure.openBusinessDay(user);
        await providerWithPrinterFailure.openShift(ShiftType.breakfast, user);
        providerWithPrinterFailure.addToCart(
          providerWithPrinterFailure.products.first,
        );

        try {
          await providerWithPrinterFailure.processPayment(
            tenderType: TenderType.cash,
            cashAmount: providerWithPrinterFailure.total + 1.0,
            cardAmount: 0.0,
          );
          fail('Expected PaymentCompletionException');
        } on PaymentCompletionException catch (error) {
          expect(error.transaction.change, greaterThan(0));
          expect(providerWithPrinterFailure.transactions, hasLength(1));
          expect(providerWithPrinterFailure.cart, isEmpty);
          expect(providerWithPrinterFailure.cashTenderedDraft, 0.0);
        }
      },
    );

    test(
      'processPayment completes without printing when receipt printer is not assigned',
      () async {
        final driver = _FakePrinterDriver();
        final providerWithManager = PosProvider(
          repository: PosRepository(database),
          printerManager: PrinterManager(
            discovery: const StaticPrinterDiscovery([]),
            drivers: [driver],
          ),
        );
        final user = AppUser(
          id: '1001',
          name: 'Alex Chen',
          role: 'Cashier',
          loginTime: DateTime.now(),
        );
        providerWithManager.setUser(user);
        await providerWithManager.openBusinessDay(user);
        await providerWithManager.openShift(ShiftType.breakfast, user);
        providerWithManager.addToCart(providerWithManager.products.first);

        final txn = await providerWithManager.processPayment(
          tenderType: TenderType.cash,
          cashAmount: providerWithManager.total,
          cardAmount: 0.0,
        );

        expect(txn.total, greaterThan(0));
        expect(providerWithManager.transactions, hasLength(1));
        expect(providerWithManager.cart, isEmpty);
        expect(driver.sentDevices, isEmpty);
        expect(driver.sentBytes, isEmpty);
      },
    );

    test('processPayment uses unique transaction ids across business days', () async {
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
      final firstTxn = await provider.processPayment(
        tenderType: TenderType.cash,
        cashAmount: provider.total,
        cardAmount: 0.0,
      );

      await provider.closeShift(user);
      await provider.closeBusinessDay(user);

      await provider.openBusinessDay(user);
      await provider.openShift(ShiftType.breakfast, user);
      provider.addToCart(provider.products.first);
      final secondTxn = await provider.processPayment(
        tenderType: TenderType.cash,
        cashAmount: provider.total,
        cardAmount: 0.0,
      );

      expect(firstTxn.id, isNot(secondTxn.id));
    });

    test('provider discovers assigns and test prints by role', () async {
      final driver = _FakePrinterDriver();
      const device = PrinterDevice(
        id: 'tcp-1',
        name: 'Receipt TCP',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.50',
        port: 9100,
      );
      final providerWithManager = PosProvider(
        repository: PosRepository(database),
        printerManager: PrinterManager(
          discovery: const StaticPrinterDiscovery([device]),
          drivers: [driver],
        ),
      );

      await providerWithManager.discoverPrinters();
      expect(providerWithManager.discoveredPrinters.length, 1);
      expect(providerWithManager.discoveredPrinters.first.id, device.id);

      providerWithManager.assignPrinterRole(PrinterRole.receipt, device);
      expect(
        providerWithManager.assignedPrinterForRole(PrinterRole.receipt)?.id,
        device.id,
      );

      await providerWithManager.testPrinter(PrinterRole.receipt);
      expect(driver.sentDevices.single.id, device.id);
      expect(driver.sentBytes.single, isNotEmpty);
      expect(
        String.fromCharCodes(driver.sentBytes.single),
        contains('EPSON PRINTER TEST'),
      );

      driver.sentDevices.clear();
      driver.sentBytes.clear();

      await providerWithManager.testPrinterConnection(PrinterRole.receipt);
      expect(driver.sentDevices.single.id, device.id);
      expect(driver.sentBytes, isEmpty);

      providerWithManager.unassignPrinterRole(PrinterRole.receipt);
      expect(
        providerWithManager.assignedPrinterForRole(PrinterRole.receipt),
        isNull,
      );
    });
  });
}
