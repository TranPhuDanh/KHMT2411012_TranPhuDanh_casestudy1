import 'package:flutter/material.dart';

/// Model lưu trữ tiêu chí lọc cho Màn hình Bộ lọc (FilterScreen)
class FilterCriteria {
  final bool selectAllTypes; // true nếu chọn Tất cả loại giao dịch
  final bool includeIncome;  // true nếu chọn Thu nhập
  final bool includeExpense; // true nếu chọn Chi tiêu
  final String category;     // Tên danh mục hoặc 'Tất cả danh mục'
  final String timeRange;    // 'Hôm nay', '7 ngày qua', 'Tháng này', 'Tùy chỉnh'
  final DateTimeRange? customDateRange; // Khoảng ngày khi chọn Tùy chỉnh

  const FilterCriteria({
    this.selectAllTypes = true,
    this.includeIncome = false,
    this.includeExpense = false,
    this.category = 'Tất cả danh mục',
    this.timeRange = 'Hôm nay',
    this.customDateRange,
  });

  FilterCriteria copyWith({
    bool? selectAllTypes,
    bool? includeIncome,
    bool? includeExpense,
    String? category,
    String? timeRange,
    DateTimeRange? customDateRange,
  }) {
    return FilterCriteria(
      selectAllTypes: selectAllTypes ?? this.selectAllTypes,
      includeIncome: includeIncome ?? this.includeIncome,
      includeExpense: includeExpense ?? this.includeExpense,
      category: category ?? this.category,
      timeRange: timeRange ?? this.timeRange,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }

  @override
  String toString() {
    return 'FilterCriteria(selectAllTypes: $selectAllTypes, includeIncome: $includeIncome, includeExpense: $includeExpense, category: $category, timeRange: $timeRange)';
  }
}
