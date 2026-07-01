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
  final bool isVoided;
  final String? voidedByName;
  final String? voidedById;
  final DateTime? voidedAt;
  final String? shiftId;
  final String? cashierId;
  final String? cashierName;

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
    this.isVoided = false,
    this.voidedByName,
    this.voidedById,
    this.voidedAt,
    this.shiftId,
    this.cashierId,
    this.cashierName,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Transaction voidWith({required String voidedByName, required String voidedById}) {
    return Transaction(
      id: id,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      tenderType: tenderType,
      cashAmount: cashAmount,
      cardAmount: cardAmount,
      change: change,
      timestamp: timestamp,
      isVoided: true,
      voidedByName: voidedByName,
      voidedById: voidedById,
      voidedAt: DateTime.now(),
      shiftId: shiftId,
      cashierId: cashierId,
      cashierName: cashierName,
    );
  }
}
