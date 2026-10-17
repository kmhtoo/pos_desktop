import '../models/transaction.dart';
import 'esc_pos_preview_renderer.dart';

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
  List<int> buildReceipt(
    Transaction transaction, {
    ReceiptTemplateSettings template,
  });
  List<int> buildTestTicket({String title, String message});
}

class ReceiptTemplateSettings {
  const ReceiptTemplateSettings({
    this.businessName = 'POS RECEIPT',
    this.receiptSubtitle = 'ORDER PAYMENT RECEIPT',
    this.businessAddress = '',
    this.businessPhone = '',
    this.footerMessage = 'Thank you for your purchase!',
    this.footerNote = 'Please come again',
  });

  final String businessName;
  final String receiptSubtitle;
  final String businessAddress;
  final String businessPhone;
  final String footerMessage;
  final String footerNote;

  ReceiptTemplateSettings copyWith({
    String? businessName,
    String? receiptSubtitle,
    String? businessAddress,
    String? businessPhone,
    String? footerMessage,
    String? footerNote,
  }) {
    return ReceiptTemplateSettings(
      businessName: businessName ?? this.businessName,
      receiptSubtitle: receiptSubtitle ?? this.receiptSubtitle,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      footerMessage: footerMessage ?? this.footerMessage,
      footerNote: footerNote ?? this.footerNote,
    );
  }
}

class BasicEscPosEncoder implements EscPosEncoder {
  const BasicEscPosEncoder();
  static const int _lineWidth = 40;

  // ESC/POS command codes
  // ignore: constant_identifier_names
  static const int ESC = 0x1B;
  // ignore: constant_identifier_names
  static const int LF = 0x0A;
  // ignore: constant_identifier_names
  static const int CR = 0x0D;

  @override
  List<int> buildReceipt(
    Transaction transaction, {
    ReceiptTemplateSettings template = const ReceiptTemplateSettings(),
  }) {
    final bytes = <int>[];

    // Initialize printer
    bytes.addAll(_initializePrinter());

    // Header
    bytes.addAll(_centerAlign());
    bytes.addAll(_fontSize(2));
    bytes.addAll(
      _safeOrDefault(template.businessName, 'POS RECEIPT').codeUnits,
    );
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());
    bytes.addAll(_fontSize(1));
    bytes.addAll(
      _safeOrDefault(
        template.receiptSubtitle,
        'ORDER PAYMENT RECEIPT',
      ).codeUnits,
    );
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());
    if (template.businessAddress.trim().isNotEmpty) {
      bytes.addAll(_safeOrDefault(template.businessAddress, '').codeUnits);
      bytes.addAll(_newLine());
    }
    if (template.businessPhone.trim().isNotEmpty) {
      bytes.addAll('Tel: ${template.businessPhone.trim()}'.codeUnits);
      bytes.addAll(_newLine());
    }
    bytes.addAll(_drawLine(char: '='));
    bytes.addAll(_newLine());

    // Receipt details
    bytes.addAll(_leftAlign());
    bytes.addAll(_formatPairLine('Receipt', transaction.id).codeUnits);
    bytes.addAll(_newLine());
    bytes.addAll(
      _formatPairLine('Date', _formatDateTime(transaction.timestamp)).codeUnits,
    );
    bytes.addAll(_newLine());
    if (transaction.cashierName != null) {
      bytes.addAll(
        _formatPairLine('Cashier', transaction.cashierName ?? '').codeUnits,
      );
      bytes.addAll(_newLine());
    }
    bytes.addAll(
      _formatPairLine('Payment', transaction.tenderType.label).codeUnits,
    );
    bytes.addAll(_newLine());
    if (transaction.isVoided) {
      bytes.addAll(_centerAlign());
      bytes.addAll(_drawLine(char: '='));
      bytes.addAll(_newLine());
      bytes.addAll([ESC, 0x21, 0x38]);
      bytes.addAll('VOID'.codeUnits);
      bytes.addAll(_resetFont());
      bytes.addAll(_newLine());
      if (transaction.voidedByName != null) {
        bytes.addAll(
          _formatPairLine('Voided by', transaction.voidedByName!).codeUnits,
        );
        bytes.addAll(_newLine());
      }
      if (transaction.voidedAt != null) {
        bytes.addAll(
          _formatPairLine(
            'Voided at',
            _formatDateTime(transaction.voidedAt!),
          ).codeUnits,
        );
        bytes.addAll(_newLine());
      }
      bytes.addAll(_drawLine(char: '='));
      bytes.addAll(_newLine());
    }
    bytes.addAll(_leftAlign());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());

    // Items header
    bytes.addAll(_fontSize(1));
    bytes.addAll(_formatItemHeader().codeUnits);
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine());
    bytes.addAll(_newLine());

    // Items
    for (final item in transaction.items) {
      final itemTotal = item.product.price * item.quantity;
      final wrappedNameLines = _wrapText(item.product.name, 22);
      for (
        var lineIndex = 0;
        lineIndex < wrappedNameLines.length;
        lineIndex++
      ) {
        final namePart = wrappedNameLines[lineIndex];
        if (lineIndex == 0) {
          bytes.addAll(
            _formatItemLine(namePart, item.quantity, itemTotal).codeUnits,
          );
        } else {
          bytes.addAll('  $namePart'.codeUnits);
        }
        bytes.addAll(_newLine());
      }
    }

    // Totals section
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine(char: '='));
    bytes.addAll(_newLine());

    // Subtotal
    bytes.addAll(_formatTotalLine('Subtotal', transaction.subtotal).codeUnits);
    bytes.addAll(_newLine());

    // Tax
    if (transaction.tax > 0) {
      bytes.addAll(_formatTotalLine('Tax', transaction.tax).codeUnits);
      bytes.addAll(_newLine());
    }

    // Total
    bytes.addAll(_fontSize(1));
    bytes.addAll(_formatTotalLine('TOTAL', transaction.total).codeUnits);
    bytes.addAll(_resetFont());
    bytes.addAll(_newLine());

    // Tender details
    bytes.addAll(_newLine());
    bytes.addAll(_drawLine(char: '='));
    bytes.addAll(_newLine());
    bytes.addAll(
      _formatTotalLine('Tendered', _tenderedAmount(transaction)).codeUnits,
    );
    bytes.addAll(_newLine());
    if (transaction.tenderType == TenderType.split) {
      bytes.addAll(_formatTotalLine('Card', transaction.cardAmount).codeUnits);
      bytes.addAll(_newLine());
      bytes.addAll(_formatTotalLine('Cash', transaction.cashAmount).codeUnits);
      bytes.addAll(_newLine());
    }

    // Change (if cash)
    if (transaction.tenderType == TenderType.cash && transaction.change > 0) {
      bytes.addAll(_fontSize(1));
      bytes.addAll(_formatTotalLine('Change', transaction.change).codeUnits);
      bytes.addAll(_resetFont());
      bytes.addAll(_newLine());
    }

    // Footer
    bytes.addAll(_newLine());
    bytes.addAll(_centerAlign());
    bytes.addAll(_drawLine(char: '='));
    bytes.addAll(_newLine());
    bytes.addAll(
      _safeOrDefault(
        template.footerMessage,
        'Thank you for your purchase!',
      ).codeUnits,
    );
    bytes.addAll(_newLine());
    bytes.addAll(
      _safeOrDefault(template.footerNote, 'Please come again').codeUnits,
    );
    bytes.addAll(_newLine());
    bytes.addAll(_leftAlign());

    // Cut paper
    bytes.addAll(_cutPaper());

    return bytes;
  }

  String buildReceiptPreviewText(
    Transaction transaction, {
    ReceiptTemplateSettings template = const ReceiptTemplateSettings(),
  }) {
    final bytes = buildReceipt(transaction, template: template);
    return const EscPosPreviewRenderer().toPlainText(bytes);
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

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  List<int> _drawLine({String char = '-'}) {
    final line = List.filled(_lineWidth, char).join('');
    return line.codeUnits;
  }

  String _formatItemHeader() {
    return 'Item'.padRight(22) + 'Qty'.padLeft(4) + 'Amount'.padLeft(14);
  }

  String _formatItemLine(String name, int quantity, double total) {
    final qtyStr = quantity.toString();
    final priceStr = '\$${total.toStringAsFixed(2)}';
    return name.padRight(22) + qtyStr.padLeft(4) + priceStr.padLeft(14);
  }

  String _formatTotalLine(String label, double amount) {
    final amountStr = '\$${amount.toStringAsFixed(2)}';
    return label.padRight(26) + amountStr.padLeft(14);
  }

  String _formatPairLine(String label, String value) {
    final prefix = '$label: ';
    if ((prefix.length + value.length) <= _lineWidth) {
      return '$prefix$value';
    }
    final allowed = (_lineWidth - prefix.length).clamp(0, _lineWidth).toInt();
    if (allowed <= 3) {
      return '$prefix${'.' * allowed}';
    }
    final compactValue = value.length > allowed
        ? '${value.substring(0, allowed - 3)}...'
        : value;
    return '$prefix$compactValue';
  }

  List<String> _wrapText(String text, int width) {
    if (text.length <= width) return [text];
    final lines = <String>[];
    var start = 0;
    while (start < text.length) {
      final end = (start + width) > text.length ? text.length : start + width;
      lines.add(text.substring(start, end));
      start = end;
    }
    return lines;
  }

  double _tenderedAmount(Transaction transaction) {
    switch (transaction.tenderType) {
      case TenderType.cash:
        return transaction.cashAmount;
      case TenderType.card:
        return transaction.cardAmount;
      case TenderType.split:
        return transaction.cardAmount + transaction.cashAmount;
      case TenderType.voucher:
        return transaction.total;
    }
  }

  String _safeOrDefault(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
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
  bool _receiptHealthCheckEnabled = true;
  ReceiptTemplateSettings _receiptTemplateSettings =
      const ReceiptTemplateSettings();

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
  bool get receiptHealthCheckEnabled => _receiptHealthCheckEnabled;
  ReceiptTemplateSettings get receiptTemplateSettings =>
      _receiptTemplateSettings;

  void setReceiptHealthCheckEnabled(bool enabled) {
    _receiptHealthCheckEnabled = enabled;
  }

  void setReceiptTemplateSettings(ReceiptTemplateSettings settings) {
    _receiptTemplateSettings = settings;
  }

  @override
  Future<void> printReceipt(Transaction transaction) async {
    if (!hasAssignment(PrinterRole.receipt)) {
      return;
    }
    if (_receiptHealthCheckEnabled) {
      await testConnection(role: PrinterRole.receipt);
    }
    await printEscPos(role: PrinterRole.receipt, transaction: transaction);
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
      throw StateError(
        'Assigned printer does not support ESC/POS: ${device.id}',
      );
    }
    final driver = drivers.cast<PrinterDriver?>().firstWhere(
      (d) => d != null && d.canHandle(device),
      orElse: () => null,
    );
    if (driver == null) {
      throw StateError('No driver can handle printer: ${device.id}');
    }
    final bytes = _escPosEncoder.buildReceipt(
      transaction,
      template: _receiptTemplateSettings,
    );
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
      throw StateError(
        'Assigned printer does not support ESC/POS: ${device.id}',
      );
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

  Future<void> testConnection({required PrinterRole role}) async {
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
