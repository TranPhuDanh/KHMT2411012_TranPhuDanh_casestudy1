import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test1111/models/filter_criteria.dart';
import 'package:test1111/screens/filter_screen.dart';
import 'package:test1111/screens/profile_screen.dart';
import 'package:test1111/screens/statistics_screen.dart';

void main() {
  group('Kiểm thử Màn hình Thống kê (StatisticsView) - Buổi 7', () {
    testWidgets('Hiển thị đầy đủ tiêu đề, các nút kỳ hạn và biểu đồ thống kê', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticsView(),
          ),
        ),
      );

      // Kiểm tra tiêu đề Thống kê
      expect(find.text('Thống kê'), findsOneWidget);

      // Kiểm tra 3 nút lọc kỳ hạn
      expect(find.text('Tháng này'), findsOneWidget);
      expect(find.text('Tháng trước'), findsOneWidget);
      expect(find.text('Năm nay'), findsOneWidget);

      // Kiểm tra tổng chi tiêu tháng này (5.000.000 đ)
      expect(find.text('5.000.000 đ'), findsOneWidget);
      expect(find.text('Tổng chi tiêu'), findsOneWidget);

      // Kiểm tra các danh mục phân rã và tỷ lệ % theo mockup
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('2.000.000 đ'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);

      expect(find.text('Mua sắm'), findsOneWidget);
      expect(find.text('1.500.000 đ'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);

      expect(find.text('Đi lại'), findsOneWidget);
      expect(find.text('700.000 đ'), findsOneWidget);
      expect(find.text('14%'), findsOneWidget);

      expect(find.text('Học tập'), findsOneWidget);
      expect(find.text('500.000 đ'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);

      expect(find.text('Khác'), findsOneWidget);
      expect(find.text('300.000 đ'), findsOneWidget);
      expect(find.text('6%'), findsOneWidget);
    });

    testWidgets('Chuyển đổi sang Tháng trước và Năm nay cập nhật số liệu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticsView(),
          ),
        ),
      );

      // Nhấn nút Tháng trước
      await tester.tap(find.text('Tháng trước'));
      await tester.pumpAndSettle();

      expect(find.text('1.800.000 đ'), findsOneWidget);

      // Nhấn nút Năm nay
      await tester.tap(find.text('Năm nay'));
      await tester.pumpAndSettle();

      expect(find.text('7.400.000 đ'), findsOneWidget);
    });

    testWidgets('Màn hình StatisticsScreen độc lập khởi tạo Scaffold và hiển thị StatisticsView', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsScreen(),
        ),
      );

      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.byType(StatisticsView), findsOneWidget);
      expect(find.text('Thống kê'), findsOneWidget);
      expect(find.text('5.000.000 đ'), findsOneWidget);
    });
  });

  group('Kiểm thử Màn hình Cá nhân (ProfileView) - Buổi 7', () {
    testWidgets('Hiển thị thông tin cá nhân và danh sách 6 mục thiết lập', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileView(),
          ),
        ),
      );

      // Tiêu đề & Thông tin cá nhân
      expect(find.text('Cá nhân'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('nguyenvana@example.com'), findsOneWidget);

      // 6 mục tùy chọn
      expect(find.text('Thông tin cá nhân'), findsOneWidget);
      expect(find.text('Cài đặt ngân sách'), findsOneWidget);
      expect(find.text('Danh mục chi tiêu'), findsOneWidget);
      expect(find.text('Sao lưu dữ liệu'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
    });

    testWidgets('Nhấn Đăng xuất hiển thị hộp thoại xác nhận', (tester) async {
      bool loggedOut = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileView(
              onLogout: () {
                loggedOut = true;
              },
            ),
          ),
        ),
      );

      // Nhấn Đăng xuất
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      // Hộp thoại xuất hiện
      expect(find.text('Xác nhận đăng xuất'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'), findsOneWidget);

      // Nhấn nút Đăng xuất trong dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng xuất'));
      await tester.pumpAndSettle();

      expect(loggedOut, true);
    });
  });

  group('Kiểm thử Màn hình Bộ lọc (FilterScreen) - Buổi 7', () {
    testWidgets('Hiển thị đầy đủ các phần loại giao dịch, danh mục, thời gian và nút áp dụng', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterScreen(),
        ),
      );

      expect(find.text('Bộ lọc'), findsOneWidget);
      expect(find.text('Loại giao dịch'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Chi tiêu'), findsOneWidget);

      expect(find.text('Danh mục'), findsOneWidget);
      expect(find.text('Tất cả danh mục'), findsOneWidget);

      expect(find.text('Khoảng thời gian'), findsOneWidget);
      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('7 ngày qua'), findsOneWidget);
      expect(find.text('Tháng này'), findsOneWidget);
      expect(find.text('Tùy chỉnh'), findsOneWidget);

      expect(find.text('Áp dụng'), findsOneWidget);
    });

    testWidgets('Áp dụng bộ lọc trả về FilterCriteria chính xác', (tester) async {
      FilterCriteria? returnedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returnedFilter = await Navigator.push<FilterCriteria>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilterScreen(
                      initialFilter: FilterCriteria(
                        selectAllTypes: false,
                        includeExpense: true,
                        category: 'Ăn uống',
                        timeRange: 'Tháng này',
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Mở bộ lọc'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mở bộ lọc'));
      await tester.pumpAndSettle();

      // Kiểm tra màn hình Bộ lọc hiển thị đúng giá trị ban đầu
      expect(find.text('Bộ lọc'), findsOneWidget);

      // Bấm nút Áp dụng
      await tester.tap(find.text('Áp dụng'));
      await tester.pumpAndSettle();

      expect(returnedFilter, isNotNull);
      expect(returnedFilter!.includeExpense, true);
      expect(returnedFilter!.category, 'Ăn uống');
      expect(returnedFilter!.timeRange, 'Tháng này');
    });
  });
}
