import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';

/// Màn hình Quản lý Hạn mức Ngân sách (Thêm, Sửa, Xóa nhiều hạn mức)
class BudgetScreen extends StatefulWidget {
  final List<BudgetModel>? initialBudgets;
  final Map<String, double>? initialSpentMap;

  const BudgetScreen({
    super.key,
    this.initialBudgets,
    this.initialSpentMap,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<BudgetModel> _budgets = [];
  Map<String, double> _spentMap = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'Tất cả',
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Giải trí',
    'Giáo dục',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialBudgets != null) {
      _budgets = List.from(widget.initialBudgets!);
      _spentMap = widget.initialSpentMap != null ? Map.from(widget.initialSpentMap!) : {};
      _isLoading = false;
    } else {
      _loadBudgets();
    }
  }

  // Tải danh sách hạn mức và tính toán số tiền thực tế đã chi tiêu từ SQLite
  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    final budgets = await DatabaseHelper.instance.getAllBudgets();
    final Map<String, double> spent = {};

    for (final b in budgets) {
      final spentAmount = await DatabaseHelper.instance.getSpentForBudget(b.category);
      spent[b.category] = spentAmount;
    }

    if (mounted) {
      setState(() {
        _budgets = budgets;
        _spentMap = spent;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final absVal = amount.abs().round();
    final str = absVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${amount < 0 ? '-' : ''}${buffer.toString()} đ';
  }

  // Mở hộp thoại Thêm hoặc Sửa hạn mức
  void _showAddEditBudgetDialog({BudgetModel? budget}) {
    final isEditing = budget != null;
    final nameCtrl = TextEditingController(text: budget?.name ?? '');
    final amountCtrl = TextEditingController(
      text: budget != null ? budget.limitAmount.toInt().toString() : '',
    );
    String selectedCategory = budget?.category ?? 'Tất cả';
    String selectedPeriod = budget?.period ?? 'Hàng tháng';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Text(
                isEditing ? 'Sửa hạn mức' : 'Thêm hạn mức mới',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tên hạn mức',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Vd: Ăn uống, Tiền trọ, Chi tiêu tháng...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Áp dụng cho danh mục',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _categories.contains(selectedCategory) ? selectedCategory : 'Tất cả',
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                            if (nameCtrl.text.isEmpty || nameCtrl.text.startsWith('Hạn mức')) {
                              nameCtrl.text = val == 'Tất cả' ? 'Tổng chi tiêu tháng' : 'Hạn mức $val';
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Số tiền hạn mức (VNĐ)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập số tiền hạn mức',
                    suffixText: 'đ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Kỳ hạn',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['Hàng tháng', 'Hàng tuần', 'Tháng này'].map((p) {
                    final isSel = selectedPeriod == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: isSel,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : const Color(0xFF475569),
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setDialogState(() => selectedPeriod = p);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final rawAmount = amountCtrl.text.replaceAll('.', '').replaceAll(',', '').trim();
                final amount = double.tryParse(rawAmount);

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên hạn mức!'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập số tiền hạn mức hợp lệ!'), backgroundColor: Colors.red),
                  );
                  return;
                }

                Navigator.pop(ctx);

                if (isEditing) {
                  final updated = budget.copyWith(
                    name: name,
                    category: selectedCategory,
                    limitAmount: amount,
                    period: selectedPeriod,
                  );
                  await DatabaseHelper.instance.updateBudget(updated);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật hạn mức thành công!'), backgroundColor: Color(0xFF16A34A)),
                  );
                } else {
                  final newBudget = BudgetModel(
                    name: name,
                    category: selectedCategory,
                    limitAmount: amount,
                    period: selectedPeriod,
                  );
                  await DatabaseHelper.instance.insertBudget(newBudget);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm hạn mức mới thành công!'), backgroundColor: Color(0xFF16A34A)),
                  );
                }

                _loadBudgets();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'Cập nhật' : 'Thêm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Xác nhận xóa hạn mức
  void _confirmDeleteBudget(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa hạn mức "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (budget.id != null) {
                await DatabaseHelper.instance.deleteBudget(budget.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa hạn mức "${budget.name}"!')),
                );
                _loadBudgets();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt hạn mức ngân sách',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 26),
            tooltip: 'Thêm hạn mức mới',
            onPressed: () => _showAddEditBudgetDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBudgets,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Hộp hướng dẫn & tổng quan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quản lý nhiều hạn mức',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_budgets.length} hạn mức',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cài đặt hạn mức theo danh mục (Ăn uống, Mua sắm...) hoặc tổng tháng để theo dõi tiến độ chi tiêu theo thời gian thực.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditBudgetDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm hạn mức khác'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1D4ED8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tiêu đề danh sách
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách hạn mức đã cài đặt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Vuốt để làm mới',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_budgets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.savings_outlined, size: 54, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text(
                            'Chưa có hạn mức nào',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Hãy nhấn nút "Thêm hạn mức" để bắt đầu kiểm soát chi tiêu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditBudgetDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm hạn mức ngay'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._budgets.map((b) => _buildBudgetCard(b)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // Widget hiển thị từng thẻ hạn mức kèm thanh tiến độ
  Widget _buildBudgetCard(BudgetModel budget) {
    final spent = _spentMap[budget.category] ?? 0.0;
    final remaining = budget.limitAmount - spent;
    final progress = (spent / budget.limitAmount).clamp(0.0, 1.0);
    final percent = ((spent / budget.limitAmount) * 100).round();
    final isExceeded = spent > budget.limitAmount;

    Color progressColor;
    if (isExceeded) {
      progressColor = const Color(0xFFEF4444); // Đỏ khi vượt hạn mức
    } else if (progress > 0.8) {
      progressColor = const Color(0xFFF59E0B); // Vàng cam khi gần chạm mức
    } else {
      progressColor = const Color(0xFF10B981); // Xanh lá khi an toàn
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExceeded ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isExceeded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Danh mục & Nút thao tác
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            budget.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${budget.period}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Sửa hạn mức',
                onPressed: () => _showAddEditBudgetDialog(budget: budget),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                tooltip: 'Xóa hạn mức',
                onPressed: () => _confirmDeleteBudget(budget),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thanh tiến độ
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),

          // Số tiền đã chi & Hạn mức
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đã chi tiêu',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(spent),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tiến độ',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isExceeded ? 'Vượt hạn mức' : 'Còn lại',
                    style: TextStyle(
                      fontSize: 11,
                      color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(remaining.abs()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
