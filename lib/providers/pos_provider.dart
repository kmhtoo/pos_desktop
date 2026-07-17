import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/business_day.dart';
import '../models/shift.dart';
import '../models/suspended_order.dart';
import '../data/pos_repository.dart';
import '../services/receipt_printer.dart';

class PaymentCompletionException implements Exception {
  const PaymentCompletionException({
    required this.transaction,
    required this.cause,
  });

  final Transaction transaction;
  final Object cause;

  @override
  String toString() => 'Payment completed, but receipt printing failed: $cause';
}

class PosProvider extends ChangeNotifier {
  static const double taxRate = 0.10;
  static const List<double> supportedCashDenominations = [
    10000.0,
    1000.0,
    100.0,
    50.0,
    10.0,
    5.0,
    2.0,
    1.0,
    0.50,
    0.20,
    0.10,
    0.05,
  ];

  final PosRepository repository;
  final ReceiptPrinter _receiptPrinter;
  final PrinterManager? _printerManager;

  PosProvider({
    required this.repository,
    ReceiptPrinter? receiptPrinter,
    PrinterManager? printerManager,
  }) : _printerManager = printerManager,
       _receiptPrinter =
           receiptPrinter ?? printerManager ?? const NoOpReceiptPrinter();

  final List<Product> products = _buildProducts();
  final List<CartItem> _cart = [];
  final List<Transaction> _transactions = [];
  String _selectedCategory = 'All';
  TenderType _selectedPaymentMode = TenderType.cash;
  bool _showPaymentHistory = false;
  double _cashTenderedDraft = 0.0;
  double _cardTenderedDraft = 0.0;
  String _voucherCodeDraft = '';
  final Map<double, int> _cashDenominationCounts = {};
  AppUser? _currentUser;
  bool _useAnimatedPageTransitions = false;
  bool _oneTapPaymentEnabled = true;
  final Map<double, bool> _cashDenominationVisible = {
    for (final d in supportedCashDenominations) d: true,
  };
  final Map<double, bool> _cashDenominationEnabled = {
    for (final d in supportedCashDenominations) d: true,
  };
  List<PrinterDevice> _discoveredPrinters = [];
  bool _isDiscoveringPrinters = false;
  final List<SuspendedOrder> _suspendedOrders = [];

  BusinessDay? _currentBusinessDay;
  Shift? _currentShift;
  final List<Shift> _shifts = [];

  // ── Init (loads persisted state on startup) ───────────────────────────────────

  Future<void> init() async {
    _currentBusinessDay = await repository.loadActiveBusinessDay();

    if (_currentBusinessDay != null) {
      final shifts = await repository.loadShiftsForDay(
        _currentBusinessDay!.id,
      );
      _shifts
        ..clear()
        ..addAll(shifts);
      _currentShift = _shifts.where((s) => s.isOpen).firstOrNull;

      for (final shift in _shifts) {
        final txns = await repository.loadTransactionsForShift(shift.id);
        _transactions.addAll(txns);
      }
      _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (_currentShift != null) {
        _suspendedOrders
          ..clear()
          ..addAll(
            await repository.loadSuspendedOrdersForShift(_currentShift!.id),
          );
      }
    }

    notifyListeners();
  }

  // ── User ──────────────────────────────────────────────────────────────────────

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get selectedCategory => _selectedCategory;
  TenderType get selectedPaymentMode => _selectedPaymentMode;
  bool get showPaymentHistory => _showPaymentHistory;
  List<TenderType> get paymentModes =>
      TenderType.values.where((mode) => mode != TenderType.split).toList();
  double get cashTenderedDraft => _cashTenderedDraft;
  double get cardTenderedDraft => _cardTenderedDraft;
  String get voucherCodeDraft => _voucherCodeDraft;
  List<MapEntry<double, int>> get cashTenderLinesDraft {
    final lines = _cashDenominationCounts.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return List.unmodifiable(lines);
  }
  int cashTenderCountFor(double denomination) =>
      _cashDenominationCounts[denomination] ?? 0;
  double get tenderedAmountDraft => switch (_selectedPaymentMode) {
    TenderType.cash => _cashTenderedDraft,
    TenderType.split => _cardTenderedDraft,
    TenderType.voucher => _voucherCodeDraft.isEmpty ? 0.0 : total,
    TenderType.card => 0.0,
  };
  double get amountDueDraft =>
      (total - tenderedAmountDraft).clamp(0.0, double.infinity);
  double get cashChangeDraft =>
      (_cashTenderedDraft - total).clamp(0.0, double.infinity);
  AppUser? get currentUser => _currentUser;
  bool get useAnimatedPageTransitions => _useAnimatedPageTransitions;
  bool get oneTapPaymentEnabled => _oneTapPaymentEnabled;
  bool get hasPrinterManager => _printerManager != null;
  bool get isDiscoveringPrinters => _isDiscoveringPrinters;
  List<PrinterDevice> get discoveredPrinters =>
      List.unmodifiable(_discoveredPrinters);
  List<PrinterRole> get printerRoles => PrinterRole.values;
  bool get canAccessPos => hasActiveBusinessDay && hasActiveShift;
  List<SuspendedOrder> get suspendedOrders => List.unmodifiable(_suspendedOrders);
  int get suspendedOrderCount => _suspendedOrders.length;
  bool get hasSuspendedOrders => _suspendedOrders.isNotEmpty;
  PrinterDevice? assignedPrinterForRole(PrinterRole role) =>
      _printerManager?.assignedPrinterFor(role);
  bool isCashDenominationVisible(double denomination) =>
      _cashDenominationVisible[denomination] ?? true;
  bool isCashDenominationEnabled(double denomination) =>
      _cashDenominationEnabled[denomination] ?? true;
  List<double> get visibleCashDenominations => supportedCashDenominations
      .where((d) => _cashDenominationVisible[d] ?? true)
      .toList();

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _cart.clear();
    _selectedCategory = 'All';
    _showPaymentHistory = false;
    _cashTenderedDraft = 0.0;
    _cardTenderedDraft = 0.0;
    _voucherCodeDraft = '';
    _cashDenominationCounts.clear();
    _suspendedOrders.clear();
    notifyListeners();
  }

  void setUseAnimatedPageTransitions(bool value) {
    if (_useAnimatedPageTransitions == value) return;
    _useAnimatedPageTransitions = value;
    notifyListeners();
  }

  void setOneTapPaymentEnabled(bool value) {
    if (_oneTapPaymentEnabled == value) return;
    _oneTapPaymentEnabled = value;
    notifyListeners();
  }

  Future<void> discoverPrinters() async {
    if (_printerManager == null) {
      _discoveredPrinters = [];
      notifyListeners();
      return;
    }
    _isDiscoveringPrinters = true;
    notifyListeners();
    try {
      _discoveredPrinters = await _printerManager.discoverAvailablePrinters();
    } finally {
      _isDiscoveringPrinters = false;
      notifyListeners();
    }
  }

  void assignPrinterRole(PrinterRole role, PrinterDevice device) {
    if (_printerManager == null) return;
    _printerManager.assignPrinter(role, device);
    notifyListeners();
  }

  void unassignPrinterRole(PrinterRole role) {
    if (_printerManager == null) return;
    _printerManager.unassignPrinter(role);
    notifyListeners();
  }

  Future<void> testPrinter(PrinterRole role) async {
    if (_printerManager == null) {
      throw StateError('Printer manager is not configured.');
    }
    await _printerManager.printTestPage(
      role: role,
      title: 'EPSON PRINTER TEST',
      message: '${role.name.toUpperCase()} ROLE READY',
    );
  }

  Future<void> testPrinterConnection(PrinterRole role) async {
    if (_printerManager == null) {
      throw StateError('Printer manager is not configured.');
    }
    await _printerManager.testConnection(role: role);
  }

  void setCashDenominationVisibility(double denomination, bool visible) {
    if (!_cashDenominationVisible.containsKey(denomination)) return;
    if (_cashDenominationVisible[denomination] == visible) return;
    _cashDenominationVisible[denomination] = visible;
    notifyListeners();
  }

  void setCashDenominationEnabled(double denomination, bool enabled) {
    if (!_cashDenominationEnabled.containsKey(denomination)) return;
    if (_cashDenominationEnabled[denomination] == enabled) return;
    _cashDenominationEnabled[denomination] = enabled;
    notifyListeners();
  }

  // ── Business Day ─────────────────────────────────────────────────────────────

  BusinessDay? get currentBusinessDay => _currentBusinessDay;
  bool get hasActiveBusinessDay => _currentBusinessDay?.isOpen ?? false;

  Future<void> openBusinessDay(AppUser by) async {
    if (hasActiveBusinessDay) return;
    final now = DateTime.now();
    final id =
        'BD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final bd = BusinessDay(
      id: id,
      openedAt: now,
      openedByName: by.name,
      openedById: by.id,
    );
    _currentBusinessDay = bd;
    _shifts.clear();
    _transactions.clear();
    _suspendedOrders.clear();
    _currentShift = null;
    await repository.saveBusinessDay(bd);
    notifyListeners();
  }

  Future<void> closeBusinessDay(AppUser by) async {
    if (!hasActiveBusinessDay) return;
    if (hasActiveShift) return;
    final closed = _currentBusinessDay!.close(
      closedByName: by.name,
      closedById: by.id,
    );
    _currentBusinessDay = closed;
    _suspendedOrders.clear();
    await repository.saveBusinessDay(closed);
    notifyListeners();
  }

  // ── Shifts ────────────────────────────────────────────────────────────────────

  Shift? get currentShift => _currentShift;
  List<Shift> get todayShifts => List.unmodifiable(_shifts);
  bool get hasActiveShift => _currentShift?.isOpen ?? false;

  List<ShiftType> get availableShiftTypes {
    final used = _shifts.map((s) => s.type).toSet();
    return ShiftType.values.where((t) => !used.contains(t)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> openShift(ShiftType type, AppUser by) async {
    if (!hasActiveBusinessDay) return;
    if (hasActiveShift) return;
    final used = _shifts.map((s) => s.type).toSet();
    if (used.contains(type)) return;

    final shift = Shift(
      id: 'SHF-${_shifts.length + 1}',
      businessDayId: _currentBusinessDay!.id,
      type: type,
      openedAt: DateTime.now(),
      openedByName: by.name,
      openedById: by.id,
    );
    _shifts.add(shift);
    _currentShift = shift;
    await repository.saveShift(shift);
    _suspendedOrders
      ..clear()
      ..addAll(await repository.loadSuspendedOrdersForShift(shift.id));
    notifyListeners();
  }

  Future<void> closeShift(AppUser by) async {
    if (!hasActiveShift) return;
    if (_suspendedOrders.isNotEmpty) return;
    final closed = _currentShift!.close(
      closedByName: by.name,
      closedById: by.id,
    );
    final idx = _shifts.indexWhere((s) => s.id == closed.id);
    if (idx >= 0) _shifts[idx] = closed;
    _currentShift = closed;
    _suspendedOrders.clear();
    await repository.saveShift(closed);
    notifyListeners();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────

  int get shiftReceiptCount => _transactions
      .where((t) => !t.isVoided && t.shiftId == _currentShift?.id)
      .length;

  double get shiftTotalSales => _transactions
      .where((t) => !t.isVoided && t.shiftId == _currentShift?.id)
      .fold(0.0, (s, t) => s + t.total);

  int get myReceiptCount => _transactions
      .where(
        (t) =>
            !t.isVoided &&
            t.cashierId == _currentUser?.id &&
            t.shiftId == _currentShift?.id,
      )
      .length;

  double get myTotalSales => _transactions
      .where(
        (t) =>
            !t.isVoided &&
            t.cashierId == _currentUser?.id &&
            t.shiftId == _currentShift?.id,
      )
      .fold(0.0, (s, t) => s + t.total);

  int get activeReceiptCount => myReceiptCount;
  double get activeTotalSales => myTotalSales;

  int shiftReceiptCountFor(String shiftId) =>
      _transactions.where((t) => !t.isVoided && t.shiftId == shiftId).length;

  double shiftTotalSalesFor(String shiftId) => _transactions
      .where((t) => !t.isVoided && t.shiftId == shiftId)
      .fold(0.0, (s, t) => s + t.total);

  // ── Cart ──────────────────────────────────────────────────────────────────────

  static const List<String> categories = [
    'All',
    'Beverages',
    'Food',
    'Snacks',
    'Desserts',
  ];

  List<Product> get filteredProducts => _selectedCategory == 'All'
      ? products
      : products.where((p) => p.category == _selectedCategory).toList();

  double get subtotal => _cart.fold(0.0, (s, i) => s + i.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
  int get cartItemCount => _cart.fold(0, (s, i) => s + i.quantity);
  bool get cartIsEmpty => _cart.isEmpty;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectPaymentMode(TenderType mode) {
    if (_selectedPaymentMode == mode && !_showPaymentHistory) return;
    _selectedPaymentMode = mode;
    _showPaymentHistory = false;
    notifyListeners();
  }

  void showPaymentHistoryView() {
    if (_showPaymentHistory) return;
    _showPaymentHistory = true;
    notifyListeners();
  }

  void setCashTenderedDraft(double amount) {
    final normalized = _asMoney(amount);
    if (_cashTenderedDraft == normalized && _cashDenominationCounts.isEmpty) {
      return;
    }
    _cashTenderedDraft = normalized;
    _cashDenominationCounts.clear();
    notifyListeners();
  }

  void addCashDenominationDraft(double denomination) {
    if (denomination <= 0) return;
    _cashDenominationCounts.update(
      denomination,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    _cashTenderedDraft = _asMoney(_cashTenderedDraft + denomination);
    notifyListeners();
  }

  void removeCashDenominationDraft(double denomination) {
    final currentCount = _cashDenominationCounts[denomination] ?? 0;
    if (currentCount <= 0) return;
    if (currentCount == 1) {
      _cashDenominationCounts.remove(denomination);
    } else {
      _cashDenominationCounts[denomination] = currentCount - 1;
    }
    _cashTenderedDraft = _asMoney((_cashTenderedDraft - denomination).clamp(0.0, double.infinity));
    notifyListeners();
  }

  void setCardTenderedDraft(double amount) {
    if (_cardTenderedDraft == amount) return;
    _cardTenderedDraft = amount;
    notifyListeners();
  }

  void setVoucherCodeDraft(String code) {
    if (_voucherCodeDraft == code) return;
    _voucherCodeDraft = code;
    notifyListeners();
  }

  void clearPaymentDrafts() {
    if (_cashTenderedDraft == 0.0 &&
        _cardTenderedDraft == 0.0 &&
        _voucherCodeDraft.isEmpty) {
      return;
    }
    _cashTenderedDraft = 0.0;
    _cardTenderedDraft = 0.0;
    _voucherCodeDraft = '';
    _cashDenominationCounts.clear();
    notifyListeners();
  }

  void addToCart(Product product) {
    final idx = _cart.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cart[idx].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void adjustQuantity(String productId, int delta) {
    final idx = _cart.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    _cart[idx].quantity += delta;
    if (_cart[idx].quantity <= 0) _cart.removeAt(idx);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _resetPaymentDrafts();
    notifyListeners();
  }

  Future<SuspendedOrder?> parkCurrentOrder({String? customLabel}) async {
    if (_currentShift == null || _cart.isEmpty) return null;
    final now = DateTime.now();
    final normalizedLabel = customLabel?.trim() ?? '';
    final order = SuspendedOrder(
      id: 'HOLD-${now.microsecondsSinceEpoch}',
      shiftId: _currentShift!.id,
      orderLabel: normalizedLabel.isEmpty
          ? _nextSuspendedOrderLabel()
          : normalizedLabel,
      items: _cart
          .map((item) => CartItem(product: item.product, quantity: item.quantity))
          .toList(),
      createdAt: now,
      updatedAt: now,
      cashierId: _currentUser?.id,
      cashierName: _currentUser?.name,
    );
    await repository.saveSuspendedOrder(order);
    _suspendedOrders.insert(0, order);
    _cart.clear();
    _resetPaymentDrafts();
    _showPaymentHistory = false;
    notifyListeners();
    return order;
  }

  Future<bool> resumeSuspendedOrder(String orderId) async {
    if (_cart.isNotEmpty) return false;
    final index = _suspendedOrders.indexWhere((order) => order.id == orderId);
    if (index < 0) return false;
    final order = _suspendedOrders.removeAt(index);
    _cart
      ..clear()
      ..addAll(
        order.items
            .map((item) => CartItem(product: item.product, quantity: item.quantity)),
      );
    _resetPaymentDrafts();
    _showPaymentHistory = false;
    await repository.deleteSuspendedOrder(order.id);
    notifyListeners();
    return true;
  }

  Future<bool> deleteSuspendedOrder(String orderId) async {
    final index = _suspendedOrders.indexWhere((order) => order.id == orderId);
    if (index < 0) return false;
    _suspendedOrders.removeAt(index);
    await repository.deleteSuspendedOrder(orderId);
    notifyListeners();
    return true;
  }

  // ── Transactions ──────────────────────────────────────────────────────────────

  Future<void> voidTransaction(String txnId) async {
    final user = _currentUser;
    if (user == null) return;
    final idx = _transactions.indexWhere((t) => t.id == txnId);
    if (idx < 0 || _transactions[idx].isVoided) return;
    final voided = _transactions[idx].voidWith(
      voidedByName: user.name,
      voidedById: user.id,
    );
    _transactions[idx] = voided;
    await repository.updateTransactionVoid(voided);
    notifyListeners();
  }

  Future<Transaction> processPayment({
    required TenderType tenderType,
    required double cashAmount,
    required double cardAmount,
  }) async {
    double change = 0.0;
    if (tenderType == TenderType.cash) {
      change = cashAmount - total;
    }

    final txn = Transaction(
      id: 'TXN-${DateTime.now().microsecondsSinceEpoch}',
      items: _cart
          .map((i) => CartItem(product: i.product, quantity: i.quantity))
          .toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      tenderType: tenderType,
      cashAmount: cashAmount,
      cardAmount: cardAmount,
      change: change < 0 ? 0.0 : change,
      timestamp: DateTime.now(),
      shiftId: _currentShift?.id,
      cashierId: _currentUser?.id,
      cashierName: _currentUser?.name,
    );

    _transactions.insert(0, txn);
    await repository.insertTransaction(txn);
    clearCart();
    try {
      await _receiptPrinter.printReceipt(txn);
    } catch (error) {
      throw PaymentCompletionException(
        transaction: txn,
        cause: error,
      );
    }
    return txn;
  }

  void _resetPaymentDrafts() {
    _cashTenderedDraft = 0.0;
    _cardTenderedDraft = 0.0;
    _voucherCodeDraft = '';
    _cashDenominationCounts.clear();
  }

  String _nextSuspendedOrderLabel() {
    var maxNumber = 0;
    for (final order in _suspendedOrders) {
      final match = RegExp(r'^Saved Order #(\d+)$').firstMatch(order.orderLabel);
      if (match == null) continue;
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed > maxNumber) {
        maxNumber = parsed;
      }
    }
    return 'Saved Order #${maxNumber + 1}';
  }

  // ── Products ──────────────────────────────────────────────────────────────────

  static List<Product> _buildProducts() => [
    const Product(
      id: 'bev1',
      name: 'Espresso',
      price: 2.50,
      category: 'Beverages',
      color: Color(0xFF6F4E37),
      emoji: '☕',
    ),
    const Product(
      id: 'bev2',
      name: 'Latte',
      price: 4.50,
      category: 'Beverages',
      color: Color(0xFFC8A882),
      emoji: '☕',
    ),
    const Product(
      id: 'bev3',
      name: 'Cappuccino',
      price: 4.00,
      category: 'Beverages',
      color: Color(0xFFD2691E),
      emoji: '☕',
    ),
    const Product(
      id: 'bev4',
      name: 'Cold Brew',
      price: 5.00,
      category: 'Beverages',
      color: Color(0xFF3E1C00),
      emoji: '🧊',
    ),
    const Product(
      id: 'bev5',
      name: 'Green Tea',
      price: 3.00,
      category: 'Beverages',
      color: Color(0xFF4CAF50),
      emoji: '🍵',
    ),
    const Product(
      id: 'bev6',
      name: 'Orange Juice',
      price: 3.50,
      category: 'Beverages',
      color: Color(0xFFFF9800),
      emoji: '🍊',
    ),
    const Product(
      id: 'bev7',
      name: 'Smoothie',
      price: 5.50,
      category: 'Beverages',
      color: Color(0xFFE91E63),
      emoji: '🥤',
    ),
    const Product(
      id: 'bev8',
      name: 'Water',
      price: 1.50,
      category: 'Beverages',
      color: Color(0xFF2196F3),
      emoji: '💧',
    ),
    const Product(
      id: 'food1',
      name: 'Sandwich',
      price: 6.50,
      category: 'Food',
      color: Color(0xFFFF8F00),
      emoji: '🥪',
    ),
    const Product(
      id: 'food2',
      name: 'Burger',
      price: 9.00,
      category: 'Food',
      color: Color(0xFFBF360C),
      emoji: '🍔',
    ),
    const Product(
      id: 'food3',
      name: 'Pizza Slice',
      price: 4.50,
      category: 'Food',
      color: Color(0xFFE53935),
      emoji: '🍕',
    ),
    const Product(
      id: 'food4',
      name: 'Caesar Salad',
      price: 7.50,
      category: 'Food',
      color: Color(0xFF388E3C),
      emoji: '🥗',
    ),
    const Product(
      id: 'food5',
      name: 'Pasta',
      price: 10.00,
      category: 'Food',
      color: Color(0xFFFBC02D),
      emoji: '🍝',
    ),
    const Product(
      id: 'food6',
      name: 'Wrap',
      price: 7.00,
      category: 'Food',
      color: Color(0xFFF57C00),
      emoji: '🌯',
    ),
    const Product(
      id: 'snk1',
      name: 'Chips',
      price: 2.00,
      category: 'Snacks',
      color: Color(0xFFFFCA28),
      emoji: '🥔',
    ),
    const Product(
      id: 'snk2',
      name: 'Granola Bar',
      price: 2.50,
      category: 'Snacks',
      color: Color(0xFF8D6E63),
      emoji: '🍫',
    ),
    const Product(
      id: 'snk3',
      name: 'Pretzel',
      price: 2.00,
      category: 'Snacks',
      color: Color(0xFFD4A017),
      emoji: '🥨',
    ),
    const Product(
      id: 'snk4',
      name: 'Mixed Nuts',
      price: 3.50,
      category: 'Snacks',
      color: Color(0xFF795548),
      emoji: '🥜',
    ),
    const Product(
      id: 'snk5',
      name: 'Popcorn',
      price: 2.50,
      category: 'Snacks',
      color: Color(0xFFFFF176),
      emoji: '🍿',
    ),
    const Product(
      id: 'des1',
      name: 'Cheesecake',
      price: 5.50,
      category: 'Desserts',
      color: Color(0xFFFFCC80),
      emoji: '🍰',
    ),
    const Product(
      id: 'des2',
      name: 'Brownie',
      price: 3.00,
      category: 'Desserts',
      color: Color(0xFF4E342E),
      emoji: '🍫',
    ),
    const Product(
      id: 'des3',
      name: 'Cookie',
      price: 1.50,
      category: 'Desserts',
      color: Color(0xFFD4A017),
      emoji: '🍪',
    ),
    const Product(
      id: 'des4',
      name: 'Ice Cream',
      price: 4.00,
      category: 'Desserts',
      color: Color(0xFFFFCDD2),
      emoji: '🍦',
    ),
    const Product(
      id: 'des5',
      name: 'Donut',
      price: 2.50,
      category: 'Desserts',
      color: Color(0xFFFF80AB),
      emoji: '🍩',
    ),
    const Product(
      id: 'des6',
      name: 'Muffin',
      price: 3.00,
      category: 'Desserts',
      color: Color(0xFFBCAAA4),
      emoji: '🧁',
    ),
  ];

  static double _asMoney(double value) =>
      (value * 100).roundToDouble() / 100.0;
}
