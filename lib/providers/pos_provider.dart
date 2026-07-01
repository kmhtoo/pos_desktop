import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/business_day.dart';
import '../models/shift.dart';
import '../data/pos_repository.dart';

class PosProvider extends ChangeNotifier {
  static const double taxRate = 0.10;

  final PosRepository _repository;

  PosProvider({required this._repository});

  final List<Product> products = _buildProducts();
  final List<CartItem> _cart = [];
  final List<Transaction> _transactions = [];
  String _selectedCategory = 'All';
  AppUser? _currentUser;

  BusinessDay? _currentBusinessDay;
  Shift? _currentShift;
  final List<Shift> _shifts = [];

  // ── Init (loads persisted state on startup) ───────────────────────────────────

  Future<void> init() async {
    _currentBusinessDay = await _repository.loadActiveBusinessDay();

    if (_currentBusinessDay != null) {
      final shifts =
          await _repository.loadShiftsForDay(_currentBusinessDay!.id);
      _shifts
        ..clear()
        ..addAll(shifts);
      _currentShift = _shifts.where((s) => s.isOpen).firstOrNull;

      for (final shift in _shifts) {
        final txns =
            await _repository.loadTransactionsForShift(shift.id);
        _transactions.addAll(txns);
      }
      _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    notifyListeners();
  }

  // ── User ──────────────────────────────────────────────────────────────────────

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get selectedCategory => _selectedCategory;
  AppUser? get currentUser => _currentUser;

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _cart.clear();
    _selectedCategory = 'All';
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
    _currentShift = null;
    await _repository.saveBusinessDay(bd);
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
    await _repository.saveBusinessDay(closed);
    notifyListeners();
  }

  // ── Shifts ────────────────────────────────────────────────────────────────────

  Shift? get currentShift => _currentShift;
  List<Shift> get todayShifts => List.unmodifiable(_shifts);
  bool get hasActiveShift => _currentShift?.isOpen ?? false;

  List<ShiftType> get availableShiftTypes {
    final used = _shifts.map((s) => s.type).toSet();
    return ShiftType.values
        .where((t) => !used.contains(t))
        .toList()
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
    await _repository.saveShift(shift);
    notifyListeners();
  }

  Future<void> closeShift(AppUser by) async {
    if (!hasActiveShift) return;
    final closed = _currentShift!.close(
      closedByName: by.name,
      closedById: by.id,
    );
    final idx = _shifts.indexWhere((s) => s.id == closed.id);
    if (idx >= 0) _shifts[idx] = closed;
    _currentShift = closed;
    await _repository.saveShift(closed);
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
      .where((t) =>
          !t.isVoided &&
          t.cashierId == _currentUser?.id &&
          t.shiftId == _currentShift?.id)
      .length;

  double get myTotalSales => _transactions
      .where((t) =>
          !t.isVoided &&
          t.cashierId == _currentUser?.id &&
          t.shiftId == _currentShift?.id)
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
    notifyListeners();
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
    await _repository.updateTransactionVoid(voided);
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
      id: 'TXN-${(_transactions.length + 1001).toString()}',
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
    await _repository.insertTransaction(txn);
    clearCart();
    return txn;
  }

  // ── Products ──────────────────────────────────────────────────────────────────

  static List<Product> _buildProducts() => [
        const Product(
            id: 'bev1',
            name: 'Espresso',
            price: 2.50,
            category: 'Beverages',
            color: Color(0xFF6F4E37),
            emoji: '☕'),
        const Product(
            id: 'bev2',
            name: 'Latte',
            price: 4.50,
            category: 'Beverages',
            color: Color(0xFFC8A882),
            emoji: '☕'),
        const Product(
            id: 'bev3',
            name: 'Cappuccino',
            price: 4.00,
            category: 'Beverages',
            color: Color(0xFFD2691E),
            emoji: '☕'),
        const Product(
            id: 'bev4',
            name: 'Cold Brew',
            price: 5.00,
            category: 'Beverages',
            color: Color(0xFF3E1C00),
            emoji: '🧊'),
        const Product(
            id: 'bev5',
            name: 'Green Tea',
            price: 3.00,
            category: 'Beverages',
            color: Color(0xFF4CAF50),
            emoji: '🍵'),
        const Product(
            id: 'bev6',
            name: 'Orange Juice',
            price: 3.50,
            category: 'Beverages',
            color: Color(0xFFFF9800),
            emoji: '🍊'),
        const Product(
            id: 'bev7',
            name: 'Smoothie',
            price: 5.50,
            category: 'Beverages',
            color: Color(0xFFE91E63),
            emoji: '🥤'),
        const Product(
            id: 'bev8',
            name: 'Water',
            price: 1.50,
            category: 'Beverages',
            color: Color(0xFF2196F3),
            emoji: '💧'),
        const Product(
            id: 'food1',
            name: 'Sandwich',
            price: 6.50,
            category: 'Food',
            color: Color(0xFFFF8F00),
            emoji: '🥪'),
        const Product(
            id: 'food2',
            name: 'Burger',
            price: 9.00,
            category: 'Food',
            color: Color(0xFFBF360C),
            emoji: '🍔'),
        const Product(
            id: 'food3',
            name: 'Pizza Slice',
            price: 4.50,
            category: 'Food',
            color: Color(0xFFE53935),
            emoji: '🍕'),
        const Product(
            id: 'food4',
            name: 'Caesar Salad',
            price: 7.50,
            category: 'Food',
            color: Color(0xFF388E3C),
            emoji: '🥗'),
        const Product(
            id: 'food5',
            name: 'Pasta',
            price: 10.00,
            category: 'Food',
            color: Color(0xFFFBC02D),
            emoji: '🍝'),
        const Product(
            id: 'food6',
            name: 'Wrap',
            price: 7.00,
            category: 'Food',
            color: Color(0xFFF57C00),
            emoji: '🌯'),
        const Product(
            id: 'snk1',
            name: 'Chips',
            price: 2.00,
            category: 'Snacks',
            color: Color(0xFFFFCA28),
            emoji: '🥔'),
        const Product(
            id: 'snk2',
            name: 'Granola Bar',
            price: 2.50,
            category: 'Snacks',
            color: Color(0xFF8D6E63),
            emoji: '🍫'),
        const Product(
            id: 'snk3',
            name: 'Pretzel',
            price: 2.00,
            category: 'Snacks',
            color: Color(0xFFD4A017),
            emoji: '🥨'),
        const Product(
            id: 'snk4',
            name: 'Mixed Nuts',
            price: 3.50,
            category: 'Snacks',
            color: Color(0xFF795548),
            emoji: '🥜'),
        const Product(
            id: 'snk5',
            name: 'Popcorn',
            price: 2.50,
            category: 'Snacks',
            color: Color(0xFFFFF176),
            emoji: '🍿'),
        const Product(
            id: 'des1',
            name: 'Cheesecake',
            price: 5.50,
            category: 'Desserts',
            color: Color(0xFFFFCC80),
            emoji: '🍰'),
        const Product(
            id: 'des2',
            name: 'Brownie',
            price: 3.00,
            category: 'Desserts',
            color: Color(0xFF4E342E),
            emoji: '🍫'),
        const Product(
            id: 'des3',
            name: 'Cookie',
            price: 1.50,
            category: 'Desserts',
            color: Color(0xFFD4A017),
            emoji: '🍪'),
        const Product(
            id: 'des4',
            name: 'Ice Cream',
            price: 4.00,
            category: 'Desserts',
            color: Color(0xFFFFCDD2),
            emoji: '🍦'),
        const Product(
            id: 'des5',
            name: 'Donut',
            price: 2.50,
            category: 'Desserts',
            color: Color(0xFFFF80AB),
            emoji: '🍩'),
        const Product(
            id: 'des6',
            name: 'Muffin',
            price: 3.00,
            category: 'Desserts',
            color: Color(0xFFBCAAA4),
            emoji: '🧁'),
      ];
}
