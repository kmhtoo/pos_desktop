enum ShiftType { breakfast, lunch, dinner }

extension ShiftTypeExt on ShiftType {
  String get label => switch (this) {
        ShiftType.breakfast => 'Breakfast',
        ShiftType.lunch => 'Lunch',
        ShiftType.dinner => 'Dinner',
      };

  String get emoji => switch (this) {
        ShiftType.breakfast => '🌅',
        ShiftType.lunch => '☀️',
        ShiftType.dinner => '🌙',
      };

  int get order => switch (this) {
        ShiftType.breakfast => 0,
        ShiftType.lunch => 1,
        ShiftType.dinner => 2,
      };
}

class Shift {
  final String id;
  final String businessDayId;
  final ShiftType type;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedByName;
  final String openedById;
  final String? closedByName;
  final String? closedById;

  const Shift({
    required this.id,
    required this.businessDayId,
    required this.type,
    required this.openedAt,
    required this.openedByName,
    required this.openedById,
    this.closedAt,
    this.closedByName,
    this.closedById,
  });

  bool get isOpen => closedAt == null;
  String get name => type.label;
  String get emoji => type.emoji;

  Shift close({
    required String closedByName,
    required String closedById,
  }) {
    return Shift(
      id: id,
      businessDayId: businessDayId,
      type: type,
      openedAt: openedAt,
      openedByName: openedByName,
      openedById: openedById,
      closedAt: DateTime.now(),
      closedByName: closedByName,
      closedById: closedById,
    );
  }
}
