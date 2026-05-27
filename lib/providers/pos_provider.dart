import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../models/user.dart';

class PosProvider extends ChangeNotifier {
  static const double taxRate = 0.10;

  final List<Product> products = _buildProducts();
  final List<CartItem> _cart = [];
  final List<Transaction> _transactions = [];
  String _selectedCategory = 'All';
  AppUser? _currentUser;

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get selectedCategory => _selectedCategory;
  AppUser? get currentUser => _currentUser;

  int get activeReceiptCount => _transactions.where((t) => !t.isVoided).length;
  double get activeTotalSales =>
      _transactions.where((t) => !t.isVoided).fold(0.0, (s, t) => s + t.total);

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _cart.clear();
    _transactions.clear();
    _selectedCategory = 'All';
    notifyListeners();
  }

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

  void voidTransaction(String txnId) {
    final user = _currentUser;
    if (user == null) return;
    final idx = _transactions.indexWhere((t) => t.id == txnId);
    if (idx < 0 || _transactions[idx].isVoided) return;
    _transactions[idx] = _transactions[idx].voidWith(
      voidedByName: user.name,
      voidedById: user.id,
    );
    notifyListeners();
  }

  Transaction processPayment({
    required TenderType tenderType,
    required double cashAmount,
    required double cardAmount,
  }) {
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
    );

    _transactions.insert(0, txn);
    clearCart();
    return txn;
  }

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
