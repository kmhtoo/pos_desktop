import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/models/cart_item.dart';
import 'package:flutter_pos_desktop/models/product.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/services/receipt_printer.dart';

class _FakeDriver implements PrinterDriver {
  final List<List<int>> sentPayloads = [];
  final List<PrinterDevice> sentDevices = [];

  @override
  bool canHandle(PrinterDevice device) => true;

  @override
  Future<void> sendBytes(PrinterDevice device, List<int> bytes) async {
    sentDevices.add(device);
    sentPayloads.add(bytes);
  }

  @override
  Future<void> testConnection(PrinterDevice device) async {
    sentDevices.add(device);
  }
}

void main() {
  Transaction sampleTransaction() {
    const product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 5.0,
      category: 'Beverages',
      color: Color(0xFF000000),
      emoji: '☕',
    );
    return Transaction(
      id: 'TXN-1001',
      items: [CartItem(product: product, quantity: 1)],
      subtotal: 5.0,
      tax: 0.5,
      total: 5.5,
      tenderType: TenderType.cash,
      cashAmount: 10.0,
      cardAmount: 0.0,
      change: 4.5,
      timestamp: DateTime.now(),
      shiftId: 'SHF-1',
      cashierId: '1001',
      cashierName: 'Alex',
    );
  }

  group('PrinterManager', () {
    test('discovers printers from discovery service', () async {
      final manager = PrinterManager(
        discovery: StaticPrinterDiscovery([
          const PrinterDevice(
            id: 'bt-1',
            name: 'BT Printer',
            connectionType: PrinterConnectionType.bluetooth,
            address: '00:11:22:33:44',
          ),
        ]),
        drivers: [_FakeDriver()],
      );

      final printers = await manager.discoverAvailablePrinters();
      expect(printers.length, 1);
      expect(printers.first.connectionType, PrinterConnectionType.bluetooth);
    });

    test('routes receipt print to assigned printer', () async {
      final driver = _FakeDriver();
      final printer = const PrinterDevice(
        id: 'tcp-1',
        name: 'Receipt Printer',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.55',
        port: 9100,
      );
      final manager = PrinterManager(
        discovery: const StaticPrinterDiscovery([]),
        drivers: [driver],
      );
      manager.assignPrinter(PrinterRole.receipt, printer);

      await manager.printReceipt(sampleTransaction());

      expect(driver.sentDevices.single.id, printer.id);
      expect(driver.sentPayloads.single, isNotEmpty);
    });

    test('supports printing to different assigned roles', () async {
      final driver = _FakeDriver();
      final receiptPrinter = const PrinterDevice(
        id: 'usb-1',
        name: 'Receipt USB',
        connectionType: PrinterConnectionType.usb,
        address: 'usb://001',
      );
      final kitchenPrinter = const PrinterDevice(
        id: 'tcp-2',
        name: 'Kitchen Printer',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.60',
        port: 9100,
      );
      final manager = PrinterManager(
        discovery: const StaticPrinterDiscovery([]),
        drivers: [driver],
      );
      manager.assignPrinter(PrinterRole.receipt, receiptPrinter);
      manager.assignPrinter(PrinterRole.kitchen, kitchenPrinter);

      await manager.printReceipt(sampleTransaction());
      await manager.printRaw(role: PrinterRole.kitchen, bytes: [1, 2, 3]);

      expect(driver.sentDevices.first.id, receiptPrinter.id);
      expect(driver.sentDevices.last.id, kitchenPrinter.id);
    });

    test('tests printer connection for assigned role', () async {
      final driver = _FakeDriver();
      final printer = const PrinterDevice(
        id: 'tcp-3',
        name: 'Connection Printer',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.61',
        port: 9100,
      );
      final manager = PrinterManager(
        discovery: const StaticPrinterDiscovery([]),
        drivers: [driver],
      );
      manager.assignPrinter(PrinterRole.receipt, printer);

      await manager.testConnection(role: PrinterRole.receipt);

      expect(driver.sentDevices.single.id, printer.id);
      expect(driver.sentPayloads, isEmpty);
    });

    test('formats ESC/POS receipt with proper layout', () async {
      const encoder = BasicEscPosEncoder();
      const product = Product(
        id: 'p1',
        name: 'Espresso',
        price: 3.50,
        category: 'Beverages',
        color: Color(0xFF6F4E37),
        emoji: '☕',
      );
      const product2 = Product(
        id: 'p2',
        name: 'Cappuccino with very long name',
        price: 4.50,
        category: 'Beverages',
        color: Color(0xFFC8A882),
        emoji: '☕',
      );
      final txn = Transaction(
        id: 'TXN-1002',
        items: [
          CartItem(product: product, quantity: 2),
          CartItem(product: product2, quantity: 1),
        ],
        subtotal: 12.50,
        tax: 1.25,
        total: 13.75,
        tenderType: TenderType.cash,
        cashAmount: 15.00,
        cardAmount: 0.0,
        change: 1.25,
        timestamp: DateTime(2025, 1, 15, 14, 30, 45),
        shiftId: 'SHF-001',
        cashierId: '001',
        cashierName: 'John',
      );

      final bytes = encoder.buildReceipt(txn);
      final output = String.fromCharCodes(bytes);

      // Verify receipt contains expected elements
      expect(output, contains('POS RECEIPT'));
      expect(output, contains('TXN-1002'));
      expect(output, contains('Date:'));
      expect(output, contains('Espresso'));
      expect(output, contains('Cappuccino'));
      expect(output, contains('Thank you'));
      expect(output, contains('TOTAL'));
      expect(output, contains('13.75'));
      expect(output, contains('Change'));
      expect(output, contains('John'));

      // Verify ESC/POS commands are present
      expect(bytes, contains(0x1B)); // ESC character
      expect(bytes, contains(0x0A)); // Line feed
      expect(bytes.length, greaterThan(100)); // Should be a substantial receipt
    });

    test('builds a simple Epson test ticket', () {
      const encoder = BasicEscPosEncoder();
      final bytes = encoder.buildTestTicket(
        title: 'EPSON PRINTER TEST',
        message: 'READY',
      );
      final output = String.fromCharCodes(bytes);

      expect(output, contains('EPSON PRINTER TEST'));
      expect(output, contains('Model: Epson TM-M30 Series III'));
      expect(output, contains('Status: READY'));
      expect(output, contains('TEST PRINT COMPLETE'));
      expect(bytes, contains(0x1B));
      expect(bytes, contains(0x0A));
    });
  });
}
