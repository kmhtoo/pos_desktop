import 'cart_item.dart';

class SuspendedOrder {
  const SuspendedOrder({
    required this.id,
    required this.shiftId,
    required this.orderLabel,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.cashierId,
    this.cashierName,
  });

  final String id;
  final String shiftId;
  final String orderLabel;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cashierId;
  final String? cashierName;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
}
