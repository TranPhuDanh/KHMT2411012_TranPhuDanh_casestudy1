class BudgetModel {
  final int? id;
  final String name;
  final String category; // 'Tất cả' hoặc tên danh mục cụ thể (vd: Ăn uống, Mua sắm...)
  final double limitAmount;
  final String period; // 'Hàng tháng', 'Tháng này', 'Hàng tuần'

  const BudgetModel({
    this.id,
    required this.name,
    required this.category,
    required this.limitAmount,
    this.period = 'Hàng tháng',
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'limit_amount': limitAmount,
      'period': period,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Hạn mức',
      category: map['category'] as String? ?? 'Tất cả',
      limitAmount: (map['limit_amount'] as num?)?.toDouble() ?? 0.0,
      period: map['period'] as String? ?? 'Hàng tháng',
    );
  }

  BudgetModel copyWith({
    int? id,
    String? name,
    String? category,
    double? limitAmount,
    String? period,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
    );
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, name: $name, category: $category, limitAmount: $limitAmount, period: $period)';
  }
}
