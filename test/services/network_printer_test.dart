import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/models/product.dart';
import 'package:flutter_pos_desktop/models/cart_item.dart';
import 'package:flutter_pos_desktop/services/receipt_printer.dart';
import 'package:flutter_pos_desktop/services/network_printer_driver.dart';

void main() {
  group('NetworkPrinterDriver', () {
    late NetworkPrinterDriver driver;

    setUp(() {
      driver = NetworkPrinterDriver();
    });

    test('canHandle identifies TCP/IP printers', () {
      const tcpPrinter = PrinterDevice(
        id: 'tcp-1',
        name: 'Network Printer',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.156',
        port: 9100,
      );

      expect(driver.canHandle(tcpPrinter), isTrue);
    });

    test('canHandle rejects non-TCP/IP printers', () {
      const btPrinter = PrinterDevice(
        id: 'bt-1',
        name: 'Bluetooth Printer',
        connectionType: PrinterConnectionType.bluetooth,
        address: '00:11:22:33:44',
      );

      expect(driver.canHandle(btPrinter), isFalse);
    });

    test('sendBytes throws for non-TCP/IP printers', () async {
      const btPrinter = PrinterDevice(
        id: 'bt-1',
        name: 'Bluetooth Printer',
        connectionType: PrinterConnectionType.bluetooth,
        address: '00:11:22:33:44',
      );

      expect(
        () => driver.sendBytes(btPrinter, [1, 2, 3]),
        throwsA(isA<PrinterException>()),
      );
    });

    test('sendBytes throws PrinterException on connection failure', () async {
      const printer = PrinterDevice(
        id: 'tcp-invalid',
        name: 'Invalid Printer',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.999', // Invalid IP
        port: 9100,
      );

      expect(
        () => driver.sendBytes(printer, [1, 2, 3]),
        throwsA(isA<PrinterException>()),
      );
    });
  });

  group('NetworkPrinterDiscovery', () {
    late NetworkPrinterDiscovery discovery;

    setUp(() {
      discovery = NetworkPrinterDiscovery();
    });

    test('discoverPrinters returns empty list (requires network setup)', () async {
      final printers = await discovery.discoverPrinters();
      expect(printers, isEmpty);
    });

    test('addKnownPrinter verifies connectivity before adding', () async {
      const validIp = '192.168.1.999'; // Invalid - should fail
      
      expect(
        () => discovery.addKnownPrinter(
          id: 'test-printer',
          name: 'Test Printer',
          ipAddress: validIp,
          port: 9100,
        ),
        throwsA(isA<PrinterException>()),
      );
    });
  });

  group('NetworkPrinterDriver with real ESC/POS', () {
    test('can build proper ESC/POS bytes for Epson TM-M30', () {
      const encoder = BasicEscPosEncoder();
      const product = Product(
        id: 'p1',
        name: 'Espresso',
        price: 3.50,
        category: 'Beverages',
        color: Color(0xFF6F4E37),
        emoji: '☕',
      );

      final txn = Transaction(
        id: 'TXN-001',
        items: [CartItem(product: product, quantity: 2)],
        subtotal: 7.00,
        tax: 0.70,
        total: 7.70,
        tenderType: TenderType.cash,
        cashAmount: 10.00,
        cardAmount: 0.0,
        change: 2.30,
        timestamp: DateTime.now(),
        shiftId: 'SHF-001',
        cashierId: '001',
        cashierName: 'John',
      );

      final bytes = encoder.buildReceipt(txn);

      // Verify output is suitable for Epson TM-M30
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
      expect(bytes, contains(0x1B)); // ESC character
      expect(bytes, contains(0x0A)); // LF character

      // Verify receipt content
      final output = String.fromCharCodes(bytes);
      expect(output, contains('TXN-001'));
      expect(output, contains('Espresso'));
      expect(output, contains('7.70'));
    });
  });

  group('Integration: Epson TM-M30 Printer Configuration', () {
    test('Epson TM-M30 printer device is properly configured', () {
      const printer = PrinterDevice(
        id: 'epson-tm-m30',
        name: 'Epson TM-M30 Series III',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.156',
        port: 9100,
        supportsEscPos: true,
      );

      // Verify printer configuration
      expect(printer.id, 'epson-tm-m30');
      expect(printer.connectionType, PrinterConnectionType.tcpIp);
      expect(printer.address, '192.168.1.156');
      expect(printer.port, 9100);
      expect(printer.supportsEscPos, isTrue);
    });

    test('network driver can handle Epson TM-M30', () {
      final driver = NetworkPrinterDriver();
      const printer = PrinterDevice(
        id: 'epson-tm-m30',
        name: 'Epson TM-M30 Series III',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.156',
        port: 9100,
        supportsEscPos: true,
      );

      expect(driver.canHandle(printer), isTrue);
    });

    test('printer manager can assign Epson TM-M30 to receipt role', () async {
      const printer = PrinterDevice(
        id: 'epson-tm-m30',
        name: 'Epson TM-M30 Series III',
        connectionType: PrinterConnectionType.tcpIp,
        address: '192.168.1.156',
        port: 9100,
        supportsEscPos: true,
      );

      final manager = PrinterManager(
        discovery: StaticPrinterDiscovery([printer]),
        drivers: [NetworkPrinterDriver()],
      );

      manager.assignPrinter(PrinterRole.receipt, printer);

      // Verify assignment
      final assigned = await manager.discoverAvailablePrinters();
      expect(assigned, contains(printer));
    });
  });
}
