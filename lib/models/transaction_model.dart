class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final int? categoryId;
  final String date;
  final bool isExpense;
  final String note;
  final String? createdAt;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.categoryId,
    required this.date,
    required this.isExpense,
    this.note = '',
    this.createdAt,
  });

  // Chuyển đổi từ Object sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'category': category,
      'category_id': categoryId,
      'date': date,
      'is_expense': isExpense ? 1 : 0,
      'note': note,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Chuyển đổi từ Map (SQLite query) sang Object
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Khác',
      categoryId: map['category_id'] as int?,
      date: map['date'] as String? ?? '',
      isExpense: (map['is_expense'] as int? ?? 1) == 1,
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] as String?,
    );
  }

  // Phương thức copyWith tiện lợi cho việc cập nhật đối tượng
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    int? categoryId,
    String? date,
    bool? isExpense,
    String? note,
    String? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, category: $category, date: $date, isExpense: $isExpense)';
  }
}
