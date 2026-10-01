import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test1111/models/transaction_model.dart';
import 'package:test1111/database/database_helper.dart';

void main() {
  setUpAll(() {
    // Khởi tạo sqflite FFI cho môi trường test trên Desktop / CLI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Kiểm thử TransactionModel', () {
    test('Chuyển đổi toMap và fromMap chính xác', () {
      const transaction = TransactionModel(
        id: 1,
        title: 'Ăn tối',
        amount: 65000.0,
        category: 'Ăn uống',
        date: '01/10/2026',
        isExpense: true,
        note: 'Bún bò Huế',
      );

      final map = transaction.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Ăn tối');
      expect(map['amount'], 65000.0);
      expect(map['category'], 'Ăn uống');
      expect(map['is_expense'], 1);
      expect(map['note'], 'Bún bò Huế');

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, transaction.id);
      expect(fromMap.title, transaction.title);
      expect(fromMap.amount, transaction.amount);
      expect(fromMap.category, transaction.category);
      expect(fromMap.isExpense, transaction.isExpense);
      expect(fromMap.note, transaction.note);
    });

    test('Phương thức copyWith hoạt động đúng', () {
      const transaction = TransactionModel(
        id: 2,
        title: 'Tiền điện',
        amount: 500000.0,
        category: 'Hóa đơn',
        date: '02/10/2026',
        isExpense: true,
      );

      final updated = transaction.copyWith(amount: 550000.0, title: 'Tiền điện tháng 10');
      expect(updated.id, 2);
      expect(updated.title, 'Tiền điện tháng 10');
      expect(updated.amount, 550000.0);
      expect(updated.category, 'Hóa đơn');
    });
  });

  group('Kiểm thử Database SQLite CRUD', () {
    test('Khởi tạo database và đọc dữ liệu mẫu', () async {
      final dbHelper = DatabaseHelper.instance;
      final transactions = await dbHelper.getAllTransactions();

      // Database được khởi tạo với 5 bản ghi mẫu ban đầu
      expect(transactions.isNotEmpty, true);
    });

    test('Thêm giao dịch mới vào SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const newTx = TransactionModel(
        title: 'Thưởng dự án',
        amount: 2000000.0,
        category: 'Thu nhập',
        date: '01/10/2026',
        isExpense: false,
        note: 'Thưởng hoàn thành Buổi 5 SQLite',
      );

      final insertedId = await dbHelper.insert(newTx);
      expect(insertedId > 0, true);

      final fetchedTx = await dbHelper.getTransactionById(insertedId);
      expect(fetchedTx, isNotNull);
      expect(fetchedTx!.title, 'Thưởng dự án');
      expect(fetchedTx.amount, 2000000.0);
      expect(fetchedTx.isExpense, false);
    });

    test('Cập nhật giao dịch trong SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const item = TransactionModel(
        title: 'Mua sách Flutter',
        amount: 250000.0,
        category: 'Giáo dục',
        date: '01/10/2026',
        isExpense: true,
      );

      final id = await dbHelper.insert(item);
      final updateItem = item.copyWith(id: id, amount: 280000.0, title: 'Mua sách Flutter nâng cao');
      final rowsAffected = await dbHelper.update(updateItem);
      expect(rowsAffected, 1);

      final checkItem = await dbHelper.getTransactionById(id);
      expect(checkItem!.title, 'Mua sách Flutter nâng cao');
      expect(checkItem.amount, 280000.0);
    });

    test('Xóa giao dịch khỏi SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const item = TransactionModel(
        title: 'Giao dịch tạm thời',
        amount: 10000.0,
        category: 'Khác',
        date: '01/10/2026',
        isExpense: true,
      );

      final id = await dbHelper.insert(item);
      final deleteRows = await dbHelper.delete(id);
      expect(deleteRows, 1);

      final checkItem = await dbHelper.getTransactionById(id);
      expect(checkItem, isNull);
    });

    test('Tính toán số dư và thống kê thu chi', () async {
      final dbHelper = DatabaseHelper.instance;
      final income = await dbHelper.getTotalIncome();
      final expense = await dbHelper.getTotalExpense();
      final balance = await dbHelper.getCurrentBalance();

      expect(income, isA<double>());
      expect(expense, isA<double>());
      expect(balance, (income - expense));
    });
  });
}
