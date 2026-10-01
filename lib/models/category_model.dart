class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final bool isExpense;

  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'icon': icon,
      'is_expense': isExpense ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String? ?? 'more_horiz',
      isExpense: (map['is_expense'] as int? ?? 1) == 1,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isExpense,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, isExpense: $isExpense)';
  }
}
