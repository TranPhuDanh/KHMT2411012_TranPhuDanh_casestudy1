import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

/// Dữ liệu từng phân đoạn trong Biểu đồ Donut Chart
class ChartCategoryItem {
  final String category;
  final double amount;
  final double percentage; // Tỷ lệ từ 0.0 -> 1.0
  final Color color;

  const ChartCategoryItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

/// Màn hình Thống kê (StatisticsScreen) theo đúng mockup Buổi 7
class StatisticsView extends StatefulWidget {
  final List<TransactionModel>? transactions;

  const StatisticsView({super.key, this.transactions});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  // 0: Tháng này, 1: Tháng trước, 2: Năm nay
  int _selectedPeriodIndex = 0;

  // Dữ liệu mẫu chuẩn tuyệt đối theo mockup hình ảnh Buổi 7
  final List<ChartCategoryItem> _thisMonthMockupData = const [
    ChartCategoryItem(
      category: 'Ăn uống',
      amount: 2000000,
      percentage: 0.40,
      color: Color(0xFFFF5252), // Đỏ tươi / Coral
    ),
    ChartCategoryItem(
      category: 'Mua sắm',
      amount: 1500000,
      percentage: 0.30,
      color: Color(0xFFF87171), // Hồng cam / Salmon
    ),
    ChartCategoryItem(
      category: 'Đi lại',
      amount: 700000,
      percentage: 0.14,
      color: Color(0xFF22C55E), // Xanh lá
    ),
    ChartCategoryItem(
      category: 'Học tập',
      amount: 500000,
      percentage: 0.10,
      color: Color(0xFF3B82F6), // Xanh dương
    ),
    ChartCategoryItem(
      category: 'Khác',
      amount: 300000,
      percentage: 0.06,
      color: Color(0xFFA855F7), // Tím
    ),
  ];

  final List<ChartCategoryItem> _lastMonthMockupData = const [
    ChartCategoryItem(
      category: 'Ăn uống',
      amount: 1800000,
      percentage: 0.43,
      color: Color(0xFFFF5252),
    ),
    ChartCategoryItem(
      category: 'Mua sắm',
      amount: 1200000,
      percentage: 0.29,
      color: Color(0xFFF87171),
    ),
    ChartCategoryItem(
      category: 'Đi lại',
      amount: 600000,
      percentage: 0.14,
      color: Color(0xFF22C55E),
    ),
    ChartCategoryItem(
      category: 'Học tập',
      amount: 400000,
      percentage: 0.10,
      color: Color(0xFF3B82F6),
    ),
    ChartCategoryItem(
      category: 'Khác',
      amount: 200000,
      percentage: 0.04,
      color: Color(0xFFA855F7),
    ),
  ];

  final List<ChartCategoryItem> _thisYearMockupData = const [
    ChartCategoryItem(
      category: 'Ăn uống',
      amount: 7400000,
      percentage: 0.40,
      color: Color(0xFFFF5252),
    ),
    ChartCategoryItem(
      category: 'Mua sắm',
      amount: 5550000,
      percentage: 0.30,
      color: Color(0xFFF87171),
    ),
    ChartCategoryItem(
      category: 'Đi lại',
      amount: 2590000,
      percentage: 0.14,
      color: Color(0xFF22C55E),
    ),
    ChartCategoryItem(
      category: 'Học tập',
      amount: 1850000,
      percentage: 0.10,
      color: Color(0xFF3B82F6),
    ),
    ChartCategoryItem(
      category: 'Khác',
      amount: 1110000,
      percentage: 0.06,
      color: Color(0xFFA855F7),
    ),
  ];

  // Tính toán dữ liệu phân loại chi tiêu
  List<ChartCategoryItem> _getCategoryData() {
    // Trả về dữ liệu tương ứng theo kỳ đã chọn
    switch (_selectedPeriodIndex) {
      case 1:
        return _lastMonthMockupData;
      case 2:
        return _thisYearMockupData;
      case 0:
      default:
        return _thisMonthMockupData;
    }
  }

  double _getTotalExpense(List<ChartCategoryItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount);
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
    return '${buffer.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();
    final totalExpense = _getTotalExpense(categoryData);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề Thống kê (nếu hiển thị trong tab)
          const Text(
            'Thống kê',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Hàng 3 nút lọc thời gian: Tháng này | Tháng trước | Năm nay =====
          Row(
            children: [
              Expanded(child: _buildPeriodButton('Tháng này', 0)),
              const SizedBox(width: 10),
              Expanded(child: _buildPeriodButton('Tháng trước', 1)),
              const SizedBox(width: 10),
              Expanded(child: _buildPeriodButton('Năm nay', 2)),
            ],
          ),
          const SizedBox(height: 32),

          // ===== Biểu đồ Donut Chart trung tâm =====
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: DonutChartPainter(
                      items: categoryData,
                      strokeWidth: 32,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatCurrency(totalExpense),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tổng chi tiêu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          // ===== Danh sách phân rã danh mục (Legend List) =====
          Column(
            children: categoryData.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Chấm tròn màu
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Tên danh mục
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const Spacer(),
                    // Số tiền
                    Text(
                      _formatCurrency(item.amount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tỷ lệ phần trăm
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${(item.percentage * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriodIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriodIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter vẽ biểu đồ hình vành khuyên (Donut Chart)
class DonutChartPainter extends CustomPainter {
  final List<ChartCategoryItem> items;
  final double strokeWidth;

  const DonutChartPainter({
    required this.items,
    this.strokeWidth = 32,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Bắt đầu từ 12 giờ (-pi/2)
    double startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (final item in items) {
      final sweepAngle = item.percentage * 2 * math.pi;
      paint.color = item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.strokeWidth != strokeWidth;
  }
}
