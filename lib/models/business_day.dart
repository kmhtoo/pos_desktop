class BusinessDay {
  final String id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedByName;
  final String openedById;
  final String? closedByName;
  final String? closedById;

  const BusinessDay({
    required this.id,
    required this.openedAt,
    required this.openedByName,
    required this.openedById,
    this.closedAt,
    this.closedByName,
    this.closedById,
  });

  bool get isOpen => closedAt == null;

  BusinessDay close({
    required String closedByName,
    required String closedById,
  }) {
    return BusinessDay(
      id: id,
      openedAt: openedAt,
      openedByName: openedByName,
      openedById: openedById,
      closedAt: DateTime.now(),
      closedByName: closedByName,
      closedById: closedById,
    );
  }
}
