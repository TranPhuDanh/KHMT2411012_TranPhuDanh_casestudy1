import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';

/// Màn hình Bộ lọc giao dịch (FilterScreen) theo mockup Buổi 7
class FilterScreen extends StatefulWidget {
  final FilterCriteria? initialFilter;
  final List<String>? customCategories;

  const FilterScreen({
    super.key,
    this.initialFilter,
    this.customCategories,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Loại giao dịch
  late bool _selectAllTypes;
  late bool _includeIncome;
  late bool _includeExpense;

  // Danh mục
  late String _selectedCategory;

  // Khoảng thời gian
  late String _selectedTimeRange;
  DateTimeRange? _customDateRange;

  final List<String> _defaultCategories = [
    'Tất cả danh mục',
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Học tập',
    'Giải trí',
    'Khác',
    'Thu nhập',
    'Lương',
    'Thưởng',
    'Đầu tư',
  ];

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter ?? const FilterCriteria();
    _selectAllTypes = filter.selectAllTypes;
    _includeIncome = filter.includeIncome;
    _includeExpense = filter.includeExpense;
    _selectedCategory = filter.category;
    _selectedTimeRange = filter.timeRange;
    _customDateRange = filter.customDateRange;
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      _selectAllTypes = value ?? false;
      if (_selectAllTypes) {
        _includeIncome = false;
        _includeExpense = false;
      }
    });
  }

  void _onIncomeChanged(bool? value) {
    setState(() {
      _includeIncome = value ?? false;
      _updateSelectAllStatus();
    });
  }

  void _onExpenseChanged(bool? value) {
    setState(() {
      _includeExpense = value ?? false;
      _updateSelectAllStatus();
    });
  }

  void _updateSelectAllStatus() {
    if (_includeIncome && _includeExpense) {
      _selectAllTypes = true;
      _includeIncome = false;
      _includeExpense = false;
    } else if (_includeIncome || _includeExpense) {
      _selectAllTypes = false;
    } else {
      _selectAllTypes = true;
    }
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final initialDateRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedTimeRange = 'Tùy chỉnh';
      });
    }
  }

  void _applyFilter() {
    final result = FilterCriteria(
      selectAllTypes: _selectAllTypes,
      includeIncome: _includeIncome,
      includeExpense: _includeExpense,
      category: _selectedCategory,
      timeRange: _selectedTimeRange,
      customDateRange: _customDateRange,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.customCategories ?? _defaultCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== 1. Loại giao dịch =====
                      const Text(
                        'Loại giao dịch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckboxTile(
                        title: 'Tất cả',
                        value: _selectAllTypes,
                        onChanged: _onSelectAllChanged,
                      ),
                      _buildCheckboxTile(
                        title: 'Thu nhập',
                        value: _includeIncome,
                        onChanged: _onIncomeChanged,
                      ),
                      _buildCheckboxTile(
                        title: 'Chi tiêu',
                        value: _includeExpense,
                        onChanged: _onExpenseChanged,
                      ),
                      const SizedBox(height: 24),

                      // ===== 2. Danh mục =====
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF94A3B8),
                            ),
                            items: categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== 3. Khoảng thời gian =====
                      const Text(
                        'Khoảng thời gian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadioTile(title: 'Hôm nay', value: 'Hôm nay'),
                      _buildRadioTile(title: '7 ngày qua', value: '7 ngày qua'),
                      _buildRadioTile(title: 'Tháng này', value: 'Tháng này'),
                      _buildRadioTile(
                        title: _customDateRange != null && _selectedTimeRange == 'Tùy chỉnh'
                            ? 'Tùy chỉnh (${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)})'
                            : 'Tùy chỉnh',
                        value: 'Tùy chỉnh',
                        onTapExtra: _pickCustomDateRange,
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Nút Áp dụng =====
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Áp dụng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    VoidCallback? onTapExtra,
  }) {
    final isSelected = _selectedTimeRange == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedTimeRange = value);
        if (value == 'Tùy chỉnh' && onTapExtra != null) {
          onTapExtra();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
