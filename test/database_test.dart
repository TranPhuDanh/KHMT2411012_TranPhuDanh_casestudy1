import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test1111/models/category_model.dart';
import 'package:test1111/models/transaction_model.dart';
import 'package:test1111/database/database_helper.dart';

void main() {
  setUpAll(() async {
    // Khởi tạo sqflite FFI cho môi trường test trên Desktop / CLI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbPath = await getDatabasesPath();
    await deleteDatabase('$dbPath/expense_manager.db');
  });

  group('Kiểm thử CategoryModel', () {
    test('Chuyển đổi CategoryModel toMap và fromMap chính xác', () {
      const cat = CategoryModel(
        id: 1,
        name: 'Ăn uống',
        icon: 'restaurant',
        isExpense: true,
      );

      final map = cat.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Ăn uống');
      expect(map['icon'], 'restaurant');
      expect(map['is_expense'], 1);

      final fromMap = CategoryModel.fromMap(map);
      expect(fromMap.id, cat.id);
      expect(fromMap.name, cat.name);
      expect(fromMap.icon, cat.icon);
      expect(fromMap.isExpense, cat.isExpense);
    });
  });

  group('Kiểm thử TransactionModel', () {
    test('Chuyển đổi TransactionModel toMap và fromMap chính xác', () {
      const transaction = TransactionModel(
        id: 1,
        title: 'Ăn tối',
        amount: 65000.0,
        category: 'Ăn uống',
        categoryId: 1,
        date: '01/10/2026',
        isExpense: true,
        note: 'Bún bò Huế',
      );

      final map = transaction.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Ăn tối');
      expect(map['amount'], 65000.0);
      expect(map['category'], 'Ăn uống');
      expect(map['category_id'], 1);
      expect(map['is_expense'], 1);
      expect(map['note'], 'Bún bò Huế');

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, transaction.id);
      expect(fromMap.title, transaction.title);
      expect(fromMap.amount, transaction.amount);
      expect(fromMap.category, transaction.category);
      expect(fromMap.categoryId, transaction.categoryId);
      expect(fromMap.isExpense, transaction.isExpense);
      expect(fromMap.note, transaction.note);
    });

    test('Phương thức copyWith hoạt động đúng', () {
      const transaction = TransactionModel(
        id: 2,
        title: 'Tiền điện',
        amount: 500000.0,
        category: 'Khác',
        date: '02/10/2026',
        isExpense: true,
      );

      final updated = transaction.copyWith(amount: 550000.0, title: 'Tiền điện tháng 10');
      expect(updated.id, 2);
      expect(updated.title, 'Tiền điện tháng 10');
      expect(updated.amount, 550000.0);
      expect(updated.category, 'Khác');
    });
  });

  group('Kiểm thử Database SQLite CRUD & Thống kê', () {
    test('Khởi tạo database và đọc danh mục Categories', () async {
      final dbHelper = DatabaseHelper.instance;
      final categories = await dbHelper.getAllCategories();

      expect(categories.isNotEmpty, true);
      expect(categories.any((c) => c.name == 'Ăn uống'), true);
      expect(categories.any((c) => c.name == 'Lương'), true);
    });

    test('Lọc danh mục theo loại Chi tiêu / Thu nhập', () async {
      final dbHelper = DatabaseHelper.instance;
      final expenseCats = await dbHelper.getCategoriesByType(isExpense: true);
      final incomeCats = await dbHelper.getCategoriesByType(isExpense: false);

      expect(expenseCats.every((c) => c.isExpense == true), true);
      expect(incomeCats.every((c) => c.isExpense == false), true);
    });

    test('Đọc danh sách giao dịch ban đầu', () async {
      final dbHelper = DatabaseHelper.instance;
      final transactions = await dbHelper.getAllTransactions();

      expect(transactions.isNotEmpty, true);
    });

    test('Thêm giao dịch mới vào SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const newTx = TransactionModel(
        title: 'Thưởng dự án Buổi 5',
        amount: 2500000.0,
        category: 'Thưởng',
        categoryId: 9,
        date: '01/10/2026',
        isExpense: false,
        note: 'Hoàn thành SQLite Database',
      );

      final insertedId = await dbHelper.insert(newTx);
      expect(insertedId > 0, true);

      final fetchedTx = await dbHelper.getTransactionById(insertedId);
      expect(fetchedTx, isNotNull);
      expect(fetchedTx!.title, 'Thưởng dự án Buổi 5');
      expect(fetchedTx.amount, 2500000.0);
      expect(fetchedTx.isExpense, false);
    });

    test('Cập nhật giao dịch trong SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const item = TransactionModel(
        title: 'Mua sách Flutter',
        amount: 250000.0,
        category: 'Giáo dục',
        categoryId: 5,
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
        amount: 15000.0,
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

    test('Tính toán số dư và thống kê nhóm chi tiêu', () async {
      final dbHelper = DatabaseHelper.instance;
      final income = await dbHelper.getTotalIncome();
      final expense = await dbHelper.getTotalExpense();
      final balance = await dbHelper.getCurrentBalance();
      final stats = await dbHelper.getCategoryExpenseStats();

      expect(income, isA<double>());
      expect(expense, isA<double>());
      expect(balance, (income - expense));
      expect(stats, isA<Map<String, double>>());
    });
  });
}
