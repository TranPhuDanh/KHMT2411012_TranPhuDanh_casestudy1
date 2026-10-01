import 'package:flutter_test/flutter_test.dart';
import 'package:test1111/main.dart';

void main() {
  testWidgets('Kiểm tra hiển thị Màn hình Chào mừng (WelcomeScreen)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Kiểm tra tên ứng dụng và nút Bắt đầu
    expect(find.text('Expense Manager'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
