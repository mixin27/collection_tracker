class LoanRecord {
  const LoanRecord({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.collectionId,
    required this.collectionName,
    this.itemCoverImageUrl,
    this.itemCoverImagePath,
    required this.borrowerName,
    this.borrowerContact,
    this.notes,
    required this.loanedAt,
    this.dueAt,
    this.returnedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String itemId;
  final String itemTitle;
  final String collectionId;
  final String collectionName;
  final String? itemCoverImageUrl;
  final String? itemCoverImagePath;
  final String borrowerName;
  final String? borrowerContact;
  final String? notes;
  final DateTime loanedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isReturned => returnedAt != null;
  bool get isActive => !isReturned;

  bool get isOverdue {
    if (isReturned || dueAt == null) {
      return false;
    }
    return dueAt!.isBefore(DateTime.now());
  }

  LoanRecord copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? collectionId,
    String? collectionName,
    String? itemCoverImageUrl,
    String? itemCoverImagePath,
    String? borrowerName,
    String? borrowerContact,
    String? notes,
    DateTime? loanedAt,
    DateTime? dueAt,
    DateTime? returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      itemCoverImageUrl: itemCoverImageUrl ?? this.itemCoverImageUrl,
      itemCoverImagePath: itemCoverImagePath ?? this.itemCoverImagePath,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      notes: notes ?? this.notes,
      loanedAt: loanedAt ?? this.loanedAt,
      dueAt: dueAt ?? this.dueAt,
      returnedAt: returnedAt ?? this.returnedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
