import 'cart_item.dart';

enum TenderType { cash, card, split }

extension TenderTypeX on TenderType {
  String get label {
    switch (this) {
      case TenderType.cash:
        return 'Cash';
      case TenderType.card:
        return 'Card';
      case TenderType.split:
        return 'Split';
    }
  }

  String get emoji {
    switch (this) {
      case TenderType.cash:
        return '💵';
      case TenderType.card:
        return '💳';
      case TenderType.split:
        return '⚡';
    }
  }
}

class Transaction {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final TenderType tenderType;
  final double cashAmount;
  final double cardAmount;
  final double change;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.tenderType,
    required this.cashAmount,
    required this.cardAmount,
    required this.change,
    required this.timestamp,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
