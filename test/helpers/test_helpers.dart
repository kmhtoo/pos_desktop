// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import 'package:flutter_pos_desktop/models/product.dart';
import 'package:flutter_pos_desktop/models/business_day.dart';
import 'package:flutter_pos_desktop/models/shift.dart';

class MockPosProvider extends ChangeNotifier {
  final List<Product> products = _buildTestProducts();
  final List<String> categories = ['All', 'Beverages', 'Food', 'Snacks', 'Desserts'];

  String _selectedCategory = 'All';
  AppUser? _currentUser;
  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;
  int _cartItemCount = 0;
  bool _hasActiveBusinessDay = false;
  bool _hasActiveShift = false;
  BusinessDay? _currentBusinessDay;
  Shift? _currentShift;
  final List<Shift> _shifts = [];

  String get selectedCategory => _selectedCategory;
  AppUser? get currentUser => _currentUser;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get total => _total;
  int get cartItemCount => _cartItemCount;
  bool get hasActiveBusinessDay => _hasActiveBusinessDay;
  bool get hasActiveShift => _hasActiveShift;
  List<Product> get filteredProducts => products;
  BusinessDay? get currentBusinessDay => _currentBusinessDay;
  Shift? get currentShift => _currentShift;
  List<Shift> get todayShifts => _shifts;
  List<ShiftType> get availableShiftTypes => const [];
  int get shiftReceiptCount => 0;
  double get shiftTotalSales => 0.0;

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSubtotal(double amount) {
    _subtotal = amount;
    _tax = _subtotal * 0.1;
    _total = _subtotal + _tax;
    notifyListeners();
  }

  void setCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }

  void setBusinessDayActive(bool active) {
    _hasActiveBusinessDay = active;
    if (active && _currentBusinessDay == null) {
      _currentBusinessDay = BusinessDay(
        id: 'BD-20260626',
        openedAt: DateTime.now(),
        openedByName: 'System',
        openedById: 'system',
      );
    } else if (!active) {
      _currentBusinessDay = null;
    }
    notifyListeners();
  }

  void setShiftActive(bool active) {
    _hasActiveShift = active;
    if (active && _currentShift == null) {
      _currentShift = Shift(
        id: 'SHF-1',
        businessDayId: 'BD-20260626',
        type: ShiftType.breakfast,
        openedAt: DateTime.now(),
        openedByName: 'System',
        openedById: 'system',
      );
    } else if (!active) {
      _currentShift = null;
    }
    notifyListeners();
  }

  int shiftReceiptCountFor(String shiftId) => 0;
  double shiftTotalSalesFor(String shiftId) => 0.0;

  Future<void> openBusinessDay(AppUser user) async {
    _hasActiveBusinessDay = true;
    _currentBusinessDay = BusinessDay(
      id: 'BD-${DateTime.now().toString().split(' ')[0].replaceAll('-', '')}',
      openedAt: DateTime.now(),
      openedByName: user.name,
      openedById: user.id,
    );
    notifyListeners();
  }

  Future<void> closeBusinessDay(AppUser user) async {
    _hasActiveBusinessDay = false;
    notifyListeners();
  }

  Future<void> openShift(ShiftType type, AppUser user) async {
    _hasActiveShift = true;
    _currentShift = Shift(
      id: 'SHF-${_shifts.length + 1}',
      businessDayId: _currentBusinessDay?.id ?? 'BD-unknown',
      type: type,
      openedAt: DateTime.now(),
      openedByName: user.name,
      openedById: user.id,
    );
    notifyListeners();
  }

  Future<void> closeShift(AppUser user) async {
    _hasActiveShift = false;
    _currentShift = null;
    notifyListeners();
  }

  static List<Product> _buildTestProducts() => [
        const Product(
            id: 'test1',
            name: 'Espresso',
            price: 2.50,
            category: 'Beverages',
            color: Color(0xFF6F4E37),
            emoji: '☕'),
        const Product(
            id: 'test2',
            name: 'Burger',
            price: 9.00,
            category: 'Food',
            color: Color(0xFFBF360C),
            emoji: '🍔'),
      ];
}

Widget createTestApp({
  required Widget child,
  required MockPosProvider mockProvider,
}) {
  return ChangeNotifierProvider.value(
    value: mockProvider,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

AppUser testUser() => AppUser(
      id: '1001',
      name: 'Alex Chen',
      role: 'Cashier',
      loginTime: DateTime.now(),
    );
