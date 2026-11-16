import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test1111/models/category_model.dart';
import 'package:test1111/models/transaction_model.dart';
import 'package:test1111/models/user_model.dart';
import 'package:test1111/models/budget_model.dart';
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

    test('Lưu và đọc trường transactionName (Tên giao dịch) riêng biệt', () {
      const transaction = TransactionModel(
        id: 3,
        transactionName: 'Ăn trưa',
        title: 'Cơm tấm sườn bì',
        amount: 45000.0,
        category: 'Ăn uống',
        date: '11/10/2026',
        isExpense: true,
        note: 'Ăn cùng đồng nghiệp',
      );

      final map = transaction.toMap();
      expect(map['transaction_name'], 'Ăn trưa');
      expect(map['title'], 'Cơm tấm sườn bì');
      expect(map['note'], 'Ăn cùng đồng nghiệp');

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.transactionName, 'Ăn trưa');
      expect(fromMap.title, 'Cơm tấm sườn bì');
      expect(fromMap.note, 'Ăn cùng đồng nghiệp');
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

    test('Load 5 giao dịch gần đây lên Dashboard đúng thứ tự và giới hạn', () async {
      final dbHelper = DatabaseHelper.instance;
      final recents = await dbHelper.getRecentTransactions(limit: 5);

      expect(recents.length, 5);
      // Kiểm tra danh sách được sắp xếp giảm dần theo ID (mới nhất lên đầu)
      for (int i = 0; i < recents.length - 1; i++) {
        expect(recents[i].id! >= recents[i + 1].id!, true);
      }
    });
  });

  group('Kiểm thử UserModel & Xác thực tài khoản', () {
    test('Chuyển đổi UserModel toMap và fromMap chính xác', () {
      const user = UserModel(
        id: 1,
        name: 'Trần Phú Danh',
        email: 'danh@example.com',
        password: '123',
      );
      final map = user.toMap();
      expect(map['name'], 'Trần Phú Danh');
      expect(map['email'], 'danh@example.com');
      expect(map['password'], '123');

      final fromMap = UserModel.fromMap(map);
      expect(fromMap.id, user.id);
      expect(fromMap.name, user.name);
      expect(fromMap.email, user.email);
    });

    test('Đăng nhập với tài khoản mẫu', () async {
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.loginUser('nguyenvana@example.com', '123');
      expect(user, isNotNull);
      expect(user!.email, 'nguyenvana@example.com');
    });
  });

  group('Kiểm thử BudgetModel & Quản lý nhiều hạn mức ngân sách', () {
    test('Chuyển đổi BudgetModel toMap, fromMap và copyWith chính xác', () {
      const budget = BudgetModel(
        id: 1,
        name: 'Ngân sách ăn uống',
        category: 'Ăn uống',
        limitAmount: 3000000.0,
        period: 'Hàng tháng',
      );

      final map = budget.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Ngân sách ăn uống');
      expect(map['category'], 'Ăn uống');
      expect(map['limit_amount'], 3000000.0);
      expect(map['period'], 'Hàng tháng');

      final fromMap = BudgetModel.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.name, 'Ngân sách ăn uống');
      expect(fromMap.category, 'Ăn uống');
      expect(fromMap.limitAmount, 3000000.0);
      expect(fromMap.period, 'Hàng tháng');

      final copied = budget.copyWith(limitAmount: 4500000.0);
      expect(copied.limitAmount, 4500000.0);
      expect(copied.name, budget.name);
    });

    test('Đọc danh sách hạn mức ngân sách mặc định trong SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      final budgets = await dbHelper.getAllBudgets();

      expect(budgets.isNotEmpty, true);
      expect(budgets.any((b) => b.category == 'Tất cả'), true);
      expect(budgets.any((b) => b.category == 'Ăn uống'), true);
    });

    test('Thêm hạn mức ngân sách mới vào SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      final initialCount = (await dbHelper.getAllBudgets()).length;

      const newBudget = BudgetModel(
        name: 'Hạn mức Du lịch hè',
        category: 'Khác',
        limitAmount: 5000000.0,
        period: 'Hàng tháng',
      );
      final id = await dbHelper.insertBudget(newBudget);
      expect(id, isPositive);

      final afterList = await dbHelper.getAllBudgets();
      expect(afterList.length, initialCount + 1);
      final inserted = afterList.firstWhere((b) => b.id == id);
      expect(inserted.name, 'Hạn mức Du lịch hè');
      expect(inserted.limitAmount, 5000000.0);
    });

    test('Cập nhật và xóa hạn mức ngân sách trong SQLite', () async {
      final dbHelper = DatabaseHelper.instance;
      const budget = BudgetModel(
        name: 'Hạn mức cần xóa',
        category: 'Giải trí',
        limitAmount: 1200000.0,
        period: 'Hàng tuần',
      );
      final id = await dbHelper.insertBudget(budget);

      // Cập nhật
      final updatedBudget = budget.copyWith(id: id, limitAmount: 1800000.0);
      final updateRows = await dbHelper.updateBudget(updatedBudget);
      expect(updateRows, 1);

      // Kiểm tra giá trị đã cập nhật
      final listAfterUpdate = await dbHelper.getAllBudgets();
      final updatedItem = listAfterUpdate.firstWhere((b) => b.id == id);
      expect(updatedItem.limitAmount, 1800000.0);

      // Xóa
      final deleteRows = await dbHelper.deleteBudget(id);
      expect(deleteRows, 1);

      final listAfterDelete = await dbHelper.getAllBudgets();
      expect(listAfterDelete.any((b) => b.id == id), false);
    });

    test('Tính số tiền chi tiêu thực tế theo danh mục cho hạn mức ngân sách', () async {
      final dbHelper = DatabaseHelper.instance;
      final spentAll = await dbHelper.getSpentForBudget('Tất cả');
      final spentFood = await dbHelper.getSpentForBudget('Ăn uống');

      expect(spentAll, isA<double>());
      expect(spentFood, isA<double>());
      expect(spentAll >= spentFood, true);
    });
  });
}
