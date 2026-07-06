import '../models/transaction.dart';

abstract class ReceiptPrinter {
  Future<void> printReceipt(Transaction transaction);
}

class NoOpReceiptPrinter implements ReceiptPrinter {
  const NoOpReceiptPrinter();

  @override
  Future<void> printReceipt(Transaction transaction) async {}
}

enum PrinterConnectionType { bluetooth, tcpIp, usb }

enum PrinterRole { receipt, kitchen, barcode, label }

class PrinterDevice {
  const PrinterDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    required this.address,
    this.port,
    this.vendorId,
    this.productId,
    this.supportsEscPos = true,
  });

  final String id;
  final String name;
  final PrinterConnectionType connectionType;
  final String address;
  final int? port;
  final int? vendorId;
  final int? productId;
  final bool supportsEscPos;
}

abstract class PrinterDiscovery {
  Future<List<PrinterDevice>> discoverPrinters();
}

abstract class PrinterDriver {
  bool canHandle(PrinterDevice device);

  Future<void> sendBytes(PrinterDevice device, List<int> bytes);

  Future<void> testConnection(PrinterDevice device);
}

class NoOpPrinterDriver implements PrinterDriver {
  const NoOpPrinterDriver();

  @override
  bool canHandle(PrinterDevice device) => true;

  @override
  Future<void> sendBytes(PrinterDevice device, List<int> bytes) async {}

  @override
  Future<void> testConnection(PrinterDevice device) async {}
}

abstract class EscPosEncoder {
  List<int> buildReceipt(Transaction transaction);
  List<int> buildTestTicket({
    String title,
    String message,
  });
}

class BasicEscPosEncoder implements EscPosEncoder {
  const BasicEscPosEncoder();

  // ESC/POS command codes
  // ignore: constant_identifier_names
  static const int ESC = 0x1B;
  // ignore: constant_identifier_names
  static const int LF = 0x0A;
  // ignore: constant_identifier_names
  static const int CR = 0x0D;

  @override
  List<int> buildReceipt(Transaction transaction) {
    final bytes = <int>[];

    // Initialize printer
    bytes.addAll(_initializePrinter());

    // Header
    bytes.addAll(_centerAlign());
    bytes.addAll(_fontSize(2)); // Double height, double width
    bytes.addAll('POS RECEIPT'.codeUnits);
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());
    bytes.addAll(_newLine());

    // Receipt ID and timestamp
    bytes.addAll(_leftAlign());
    bytes.addAll('Receipt: ${transaction.id}'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(_formatDateTime(transaction.timestamp));
    bytes.addAll(_newLine());
    if (transaction.cashierName != null) {
      bytes.addAll('Cashier: ${transaction.cashierName}'.codeUnits);
      bytes.addAll(_newLine());
    }
    bytes.addAll(_newLine());

    // Items header
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());
    bytes.addAll('Item'.codeUnits);
    bytes.addAll('Qty'.codeUnits);
    bytes.addAll('Price'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());

    // Items
    for (final item in transaction.items) {
      final itemTotal = item.product.price * item.quantity;
      bytes.addAll(
        _formatItemLine(
          item.product.name,
          item.quantity,
          item.product.price,
          itemTotal,
        ).codeUnits,
      );
      bytes.addAll(_newLine());
    }

    // Totals section
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());

    // Subtotal
    bytes.addAll(
      _formatTotalLine('Subtotal', transaction.subtotal).codeUnits,
    );
    bytes.addAll(_newLine());

    // Tax
    if (transaction.tax > 0) {
      bytes.addAll(
        _formatTotalLine('Tax', transaction.tax).codeUnits,
      );
      bytes.addAll(_newLine());
    }

    // Total
    bytes.addAll(_fontSize(1)); // Bold
    bytes.addAll(
      _formatTotalLine('TOTAL', transaction.total).codeUnits,
    );
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());

    // Payment info
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());
    bytes.addAll(
      'Payment: ${transaction.tenderType.label}'.codeUnits,
    );
    bytes.addAll(_newLine());
    bytes.addAll(
      'Amount: \$${transaction.cashAmount > 0 ? transaction.cashAmount : transaction.cardAmount}'.codeUnits,
    );
    bytes.addAll(_newLine());

    // Change (if cash)
    if (transaction.tenderType == TenderType.cash &&
        transaction.change > 0) {
      bytes.addAll(_fontSize(1)); // Bold
      bytes.addAll(
        'Change: \$${transaction.change.toStringAsFixed(2)}'.codeUnits,
      );
      bytes.addAll(_resetFont());
      bytes.addAll(_newLine());
    }

    // Footer
    bytes.addAll(_newLine());
    bytes.addAll(_newLine());
    bytes.addAll(_centerAlign());
    bytes.addAll('Thank you for your purchase!'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(_leftAlign());

    // Cut paper
    bytes.addAll(_cutPaper());

    return bytes;
  }

  @override
  List<int> buildTestTicket({
    String title = 'EPSON PRINTER TEST',
    String message = 'Connection OK',
  }) {
    final bytes = <int>[];

    bytes.addAll(_initializePrinter());
    bytes.addAll(_centerAlign());
    bytes.addAll(_fontSize(2));
    bytes.addAll(title.codeUnits);
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());
    bytes.addAll(_newLine());

    bytes.addAll(_leftAlign());
    bytes.addAll('Model: Epson TM-M30 Series III'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll('Status: $message'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(
      'Time: ${DateTime.now().toIso8601String().replaceFirst('T', ' ').split('.').first}'
          .codeUnits,
    );
    bytes.addAll(_newLine());
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());
    bytes.addAll(_centerAlign());
    bytes.addAll('TEST PRINT COMPLETE'.codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(_leftAlign());
    bytes.addAll(_newLine());
    bytes.addAll(_cutPaper());

    return bytes;
  }

  List<int> _initializePrinter() {
    return [ESC, 0x40]; // Initialize printer
  }

  List<int> _centerAlign() {
    return [ESC, 0x61, 0x01];
  }

  List<int> _leftAlign() {
    return [ESC, 0x61, 0x00];
  }

  List<int> _fontSize(int mode) {
    // mode 0 = normal, 1 = bold, 2 = double size
    if (mode == 0) return [ESC, 0x21, 0x00];
    if (mode == 1) return [ESC, 0x21, 0x08]; // Bold
    if (mode == 2) return [ESC, 0x21, 0x30]; // Double height and width
    return [];
  }

  List<int> _resetFont() {
    return [ESC, 0x21, 0x00];
  }

  List<int> _newLine() {
    return [LF];
  }

  List<int> _formatDateTime(DateTime dt) {
    final str = 'Date: ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return str.codeUnits;
  }

  List<int> _drawLine() {
    final line = List.filled(40, '-').join('');
    return line.codeUnits;
  }

  String _formatItemLine(
    String name,
    int quantity,
    double price,
    double total,
  ) {
    final qtyStr = quantity.toString();
    final priceStr = '\$${total.toStringAsFixed(2)}';
    final nameDisplay = name.length > 20 ? '${name.substring(0, 17)}...' : name;
    return nameDisplay.padRight(20) +
        qtyStr.padLeft(4) +
        priceStr.padLeft(12);
  }

  String _formatTotalLine(String label, double amount) {
    final amountStr = '\$${amount.toStringAsFixed(2)}';
    return label.padRight(28) + amountStr.padLeft(12);
  }

  List<int> _cutPaper() {
    return [ESC, 0x69]; // Partial cut
  }
}

class PrinterManager implements ReceiptPrinter {
  PrinterManager({
    required this.discovery,
    required this.drivers,
    EscPosEncoder? escPosEncoder,
  }) : _escPosEncoder = escPosEncoder ?? const BasicEscPosEncoder();

  final PrinterDiscovery discovery;
  final List<PrinterDriver> drivers;
  final EscPosEncoder _escPosEncoder;
  final Map<PrinterRole, PrinterDevice> _assignments = {};

  Future<List<PrinterDevice>> discoverAvailablePrinters() {
    return discovery.discoverPrinters();
  }

  void assignPrinter(PrinterRole role, PrinterDevice device) {
    _assignments[role] = device;
  }

  void unassignPrinter(PrinterRole role) {
    _assignments.remove(role);
  }

  PrinterDevice? assignedPrinterFor(PrinterRole role) => _assignments[role];
  Map<PrinterRole, PrinterDevice> get assignments =>
      Map.unmodifiable(_assignments);
  bool hasAssignment(PrinterRole role) => _assignments.containsKey(role);

  @override
  Future<void> printReceipt(Transaction transaction) {
    return printEscPos(role: PrinterRole.receipt, transaction: transaction);
  }

  Future<void> printEscPos({
    required PrinterRole role,
    required Transaction transaction,
  }) async {
    final device = _assignments[role];
    if (device == null) {
      throw StateError('No printer assigned for role: $role');
    }
    if (!device.supportsEscPos) {
      throw StateError('Assigned printer does not support ESC/POS: ${device.id}');
    }
    final driver = drivers.cast<PrinterDriver?>().firstWhere(
      (d) => d != null && d.canHandle(device),
      orElse: () => null,
    );
    if (driver == null) {
      throw StateError('No driver can handle printer: ${device.id}');
    }
    final bytes = _escPosEncoder.buildReceipt(transaction);
    await driver.sendBytes(device, bytes);
  }

  Future<void> printTestPage({
    required PrinterRole role,
    String title = 'EPSON PRINTER TEST',
    String message = 'Connection OK',
  }) async {
    final device = _assignments[role];
    if (device == null) {
      throw StateError('No printer assigned for role: $role');
    }
    if (!device.supportsEscPos) {
      throw StateError('Assigned printer does not support ESC/POS: ${device.id}');
    }
    final driver = drivers.cast<PrinterDriver?>().firstWhere(
      (d) => d != null && d.canHandle(device),
      orElse: () => null,
    );
    if (driver == null) {
      throw StateError('No driver can handle printer: ${device.id}');
    }
    final bytes = _escPosEncoder.buildTestTicket(
      title: title,
      message: message,
    );
    await driver.sendBytes(device, bytes);
  }

  Future<void> printRaw({
    required PrinterRole role,
    required List<int> bytes,
  }) async {
    final device = _assignments[role];
    if (device == null) {
      throw StateError('No printer assigned for role: $role');
    }
    final driver = drivers.cast<PrinterDriver?>().firstWhere(
      (d) => d != null && d.canHandle(device),
      orElse: () => null,
    );
    if (driver == null) {
      throw StateError('No driver can handle printer: ${device.id}');
    }
    await driver.sendBytes(device, bytes);
  }

  Future<void> testConnection({
    required PrinterRole role,
  }) async {
    final device = _assignments[role];
    if (device == null) {
      throw StateError('No printer assigned for role: $role');
    }
    final driver = drivers.cast<PrinterDriver?>().firstWhere(
      (d) => d != null && d.canHandle(device),
      orElse: () => null,
    );
    if (driver == null) {
      throw StateError('No driver can handle printer: ${device.id}');
    }
    await driver.testConnection(device);
  }
}

class StaticPrinterDiscovery implements PrinterDiscovery {
  const StaticPrinterDiscovery(this.devices);

  final List<PrinterDevice> devices;

  @override
  Future<List<PrinterDevice>> discoverPrinters() async => devices;
}
