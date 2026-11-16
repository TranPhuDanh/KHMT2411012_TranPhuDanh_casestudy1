import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static const String _dbName = 'expense_manager.db';
  static const int _dbVersion = 3;

  // Bảng Hạn mức Ngân sách (Budgets)
  static const String tableBudgets = 'budgets';
  static const String colBudgetId = 'id';
  static const String colBudgetName = 'name';
  static const String colBudgetCategory = 'category';
  static const String colBudgetLimitAmount = 'limit_amount';
  static const String colBudgetPeriod = 'period';

  // Bảng Người dùng (Users)
  static const String tableUsers = 'users';
  static const String colUserId = 'id';
  static const String colUserName = 'name';
  static const String colUserEmail = 'email';
  static const String colUserPassword = 'password';
  static const String colUserCreatedAt = 'created_at';

  // Bảng Danh mục (Categories)
  static const String tableCategories = 'categories';
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatIcon = 'icon';
  static const String colCatIsExpense = 'is_expense';

  // Bảng Giao dịch (Transactions)
  static const String tableTransactions = 'transactions';
  static const String colId = 'id';
  static const String colTransactionName = 'transaction_name';
  static const String colTitle = 'title';
  static const String colAmount = 'amount';
  static const String colCategory = 'category';
  static const String colCategoryId = 'category_id';
  static const String colDate = 'date';
  static const String colIsExpense = 'is_expense';
  static const String colNote = 'note';
  static const String colCreatedAt = 'created_at';

  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
      onOpen: _onOpen,
    );
  }

  // Nâng cấp database khi có thay đổi cấu trúc bảng
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableCategories (
          $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
          $colCatName TEXT NOT NULL UNIQUE,
          $colCatIcon TEXT NOT NULL,
          $colCatIsExpense INTEGER NOT NULL
        )
      ''');
      await _insertSampleCategories(db);

      try {
        await db.execute('ALTER TABLE $tableTransactions ADD COLUMN $colCategoryId INTEGER');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableTransactions'),
      ) ?? 0;
      if (count <= 5) {
        await db.delete(tableTransactions);
        await _insertSampleTransactions(db);
      }
    }
  }

  // Bật hỗ trợ Foreign Key trong SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Đảm bảo các bảng và cột mới tồn tại khi mở CSDL
  Future<void> _onOpen(Database db) async {
    try {
      await db.execute('ALTER TABLE $tableTransactions ADD COLUMN $colTransactionName TEXT');
    } catch (_) {}
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUsers (
          $colUserId INTEGER PRIMARY KEY AUTOINCREMENT,
          $colUserName TEXT NOT NULL,
          $colUserEmail TEXT NOT NULL UNIQUE,
          $colUserPassword TEXT NOT NULL,
          $colUserCreatedAt TEXT
        )
      ''');
      final userCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableUsers'),
      ) ?? 0;
      if (userCount == 0) {
        await _insertSampleUsers(db);
      }
    } catch (_) {}
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableBudgets (
          $colBudgetId INTEGER PRIMARY KEY AUTOINCREMENT,
          $colBudgetName TEXT NOT NULL,
          $colBudgetCategory TEXT NOT NULL,
          $colBudgetLimitAmount REAL NOT NULL,
          $colBudgetPeriod TEXT NOT NULL
        )
      ''');
      final budgetCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableBudgets'),
      ) ?? 0;
      if (budgetCount == 0) {
        await _insertSampleBudgets(db);
      }
    } catch (_) {}
  }

  // Khởi tạo các bảng trong Database
  Future<void> _createDB(Database db, int version) async {
    // 1. Tạo bảng Danh mục (Categories)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCategories (
        $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCatName TEXT NOT NULL UNIQUE,
        $colCatIcon TEXT NOT NULL,
        $colCatIsExpense INTEGER NOT NULL
      )
    ''');

    // 2. Tạo bảng Giao dịch (Transactions) có liên kết Khóa ngoại Foreign Key tới Categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTransactions (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTransactionName TEXT,
        $colTitle TEXT NOT NULL,
        $colAmount REAL NOT NULL,
        $colCategory TEXT NOT NULL,
        $colCategoryId INTEGER,
        $colDate TEXT NOT NULL,
        $colIsExpense INTEGER NOT NULL,
        $colNote TEXT,
        $colCreatedAt TEXT,
        FOREIGN KEY ($colCategoryId) REFERENCES $tableCategories ($colCatId) ON DELETE SET NULL
      )
    ''');

    // 3. Tạo bảng Người dùng (Users)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsers (
        $colUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUserName TEXT NOT NULL,
        $colUserEmail TEXT NOT NULL UNIQUE,
        $colUserPassword TEXT NOT NULL,
        $colUserCreatedAt TEXT
      )
    ''');

    // 4. Tạo bảng Hạn mức Ngân sách (Budgets)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableBudgets (
        $colBudgetId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colBudgetName TEXT NOT NULL,
        $colBudgetCategory TEXT NOT NULL,
        $colBudgetLimitAmount REAL NOT NULL,
        $colBudgetPeriod TEXT NOT NULL
      )
    ''');

    // 5. Khởi tạo dữ liệu mẫu ban đầu
    await _insertSampleCategories(db);
    await _insertSampleTransactions(db);
    await _insertSampleUsers(db);
    await _insertSampleBudgets(db);
  }

  // Chèn danh mục mặc định
  Future<void> _insertSampleCategories(Database db) async {
    final defaultCategories = [
      // Chi tiêu
      {'name': 'Ăn uống', 'icon': 'restaurant', 'is_expense': 1},
      {'name': 'Di chuyển', 'icon': 'directions_car', 'is_expense': 1},
      {'name': 'Mua sắm', 'icon': 'shopping_bag', 'is_expense': 1},
      {'name': 'Giải trí', 'icon': 'movie', 'is_expense': 1},
      {'name': 'Giáo dục', 'icon': 'school', 'is_expense': 1},
      {'name': 'Khác', 'icon': 'more_horiz', 'is_expense': 1},
      // Thu nhập
      {'name': 'Thu nhập', 'icon': 'attach_money', 'is_expense': 0},
      {'name': 'Lương', 'icon': 'payments', 'is_expense': 0},
      {'name': 'Thưởng', 'icon': 'card_giftcard', 'is_expense': 0},
      {'name': 'Đầu tư', 'icon': 'trending_up', 'is_expense': 0},
    ];

    for (final cat in defaultCategories) {
      await db.insert(tableCategories, cat);
    }
  }

  // Chèn dữ liệu mẫu cho giao dịch
  Future<void> _insertSampleTransactions(Database db) async {
    final sampleItems = [
      {
        colTitle: 'Tiền thuê nhà',
        colCategory: 'Khác',
        colCategoryId: 6,
        colDate: '25/08/2024',
        colAmount: 2050000.0,
        colIsExpense: 1,
        colNote: 'Tiền phòng trọ tháng 8',
        colCreatedAt: '2024-08-25T10:00:00.000',
      },
      {
        colTitle: 'Học phí',
        colCategory: 'Giáo dục',
        colCategoryId: 5,
        colDate: '30/08/2024',
        colAmount: 500000.0,
        colIsExpense: 1,
        colNote: 'Đóng học phí khóa học Flutter',
        colCreatedAt: '2024-08-30T10:00:00.000',
      },
      {
        colTitle: 'Mua sắm',
        colCategory: 'Mua sắm',
        colCategoryId: 3,
        colDate: '31/08/2024',
        colAmount: 300000.0,
        colIsExpense: 1,
        colNote: 'Mua đồ dùng cá nhân',
        colCreatedAt: '2024-08-31T10:00:00.000',
      },
      {
        colTitle: 'Lương tháng 9',
        colCategory: 'Thu nhập',
        colCategoryId: 7,
        colDate: '01/09/2024',
        colAmount: 8000000.0,
        colIsExpense: 0,
        colNote: 'Lương chuyển khoản tháng 9',
        colCreatedAt: '2024-09-01T10:00:00.000',
      },
      {
        colTitle: 'Xăng xe',
        colCategory: 'Di chuyển',
        colCategoryId: 2,
        colDate: '03/09/2024',
        colAmount: 100000.0,
        colIsExpense: 1,
        colNote: 'Đổ xăng xe máy',
        colCreatedAt: '2024-09-03T09:00:00.000',
      },
      {
        colTitle: 'Ăn trưa',
        colCategory: 'Ăn uống',
        colCategoryId: 1,
        colDate: '03/09/2024',
        colAmount: 50000.0,
        colIsExpense: 1,
        colNote: 'Ăn trưa cùng đồng nghiệp',
        colCreatedAt: '2024-09-03T12:00:00.000',
      },
    ];

    for (final item in sampleItems) {
      await db.insert(tableTransactions, item);
    }
  }

  // Chèn người dùng mẫu mặc định
  Future<void> _insertSampleUsers(Database db) async {
    try {
      await db.insert(tableUsers, {
        colUserName: 'Nguyễn Văn A',
        colUserEmail: 'nguyenvana@example.com',
        colUserPassword: '123',
        colUserCreatedAt: DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // Chèn các hạn mức ngân sách mẫu mặc định
  Future<void> _insertSampleBudgets(Database db) async {
    try {
      final sampleBudgets = [
        {
          colBudgetName: 'Tổng chi tiêu tháng',
          colBudgetCategory: 'Tất cả',
          colBudgetLimitAmount: 10000000.0,
          colBudgetPeriod: 'Hàng tháng',
        },
        {
          colBudgetName: 'Hạn mức Ăn uống',
          colBudgetCategory: 'Ăn uống',
          colBudgetLimitAmount: 3000000.0,
          colBudgetPeriod: 'Hàng tháng',
        },
        {
          colBudgetName: 'Hạn mức Mua sắm',
          colBudgetCategory: 'Mua sắm',
          colBudgetLimitAmount: 2000000.0,
          colBudgetPeriod: 'Hàng tháng',
        },
      ];
      for (final b in sampleBudgets) {
        await db.insert(tableBudgets, b);
      }
    } catch (_) {}
  }

  // ==================== CÁC PHƯƠNG THỨC CRUD CHO DANH MỤC (CATEGORIES) ====================

  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert(
      tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query(tableCategories, orderBy: '$colCatId ASC');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType({required bool isExpense}) async {
    final db = await instance.database;
    final result = await db.query(
      tableCategories,
      where: '$colCatIsExpense = ?',
      whereArgs: [isExpense ? 1 : 0],
      orderBy: '$colCatId ASC',
    );
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  // ==================== CÁC PHƯƠNG THỨC CRUD CHO GIAO DỊCH (TRANSACTIONS) ====================

  // 1. CREATE: Thêm giao dịch mới
  Future<int> insert(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert(tableTransactions, transaction.toMap());
  }

  // 2. READ: Lấy tất cả giao dịch (mới nhất lên đầu)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query(tableTransactions, orderBy: '$colId DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Lấy các giao dịch gần đây có giới hạn số lượng (mặc định 5 giao dịch)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final db = await instance.database;
    final result = await db.query(
      tableTransactions,
      orderBy: '$colId DESC',
      limit: limit,
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Lấy giao dịch theo ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTransactions,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  // 3. UPDATE: Cập nhật giao dịch
  Future<int> update(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      tableTransactions,
      transaction.toMap(),
      where: '$colId = ?',
      whereArgs: [transaction.id],
    );
  }

  // 4. DELETE: Xóa giao dịch theo ID
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableTransactions,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // Xóa toàn bộ giao dịch
  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(tableTransactions);
  }

  // ==================== TÍNH TOÁN THỐNG KÊ SQLITE ====================

  // Tính tổng thu nhập
  Future<double> getTotalIncome() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM($colAmount) as total FROM $tableTransactions WHERE $colIsExpense = 0',
    );
    final total = result.first['total'];
    if (total != null) {
      return (total as num).toDouble();
    }
    return 0.0;
  }

  // Tính tổng chi tiêu
  Future<double> getTotalExpense() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM($colAmount) as total FROM $tableTransactions WHERE $colIsExpense = 1',
    );
    final total = result.first['total'];
    if (total != null) {
      return (total as num).toDouble();
    }
    return 0.0;
  }

  // Tính số dư hiện tại (Thu nhập - Chi tiêu)
  Future<double> getCurrentBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }

  // Thống kê chi tiêu theo từng danh mục
  Future<Map<String, double>> getCategoryExpenseStats() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT $colCategory, SUM($colAmount) as total
      FROM $tableTransactions
      WHERE $colIsExpense = 1
      GROUP BY $colCategory
      ORDER BY total DESC
      ''',
    );

    final Map<String, double> stats = {};
    for (final row in result) {
      final category = row[colCategory] as String;
      final total = (row['total'] as num).toDouble();
      stats[category] = total;
    }
    return stats;
  }

  // ==================== CÁC PHƯƠNG THỨC XỬ LÝ NGƯỜI DÙNG (USERS) ====================

  // Đăng ký người dùng mới
  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert(tableUsers, user.toMap());
  }

  // Đăng nhập người dùng (kiểm tra email và mật khẩu)
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final cleanEmail = email.trim().toLowerCase();
    try {
      final res = await db.query(
        tableUsers,
        where: 'LOWER($colUserEmail) = ? AND $colUserPassword = ?',
        whereArgs: [cleanEmail, password],
      );
      if (res.isNotEmpty) {
        return UserModel.fromMap(res.first);
      }
    } catch (_) {}

    // Tài khoản mẫu mặc định
    if ((cleanEmail == 'nguyenvana@example.com' || cleanEmail == 'admin@example.com' || cleanEmail == 'danh@example.com') &&
        (password == '123' || password == '123456')) {
      return UserModel(
        id: 1,
        name: cleanEmail == 'danh@example.com' ? 'Trần Phú Danh' : 'Nguyễn Văn A',
        email: cleanEmail,
        password: password,
      );
    }
    return null;
  }

  // Tìm người dùng theo email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final res = await db.query(
        tableUsers,
        where: 'LOWER($colUserEmail) = ?',
        whereArgs: [email.trim().toLowerCase()],
      );
      if (res.isNotEmpty) {
        return UserModel.fromMap(res.first);
      }
    } catch (_) {}
    return null;
  }

  // ==================== CÁC PHƯƠNG THỨC QUẢN LÝ HẠN MỨC (BUDGETS) ====================

  // Đọc danh sách toàn bộ các hạn mức
  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await database;
    try {
      final res = await db.query(tableBudgets, orderBy: '$colBudgetId ASC');
      if (res.isNotEmpty) {
        return res.map((map) => BudgetModel.fromMap(map)).toList();
      }
    } catch (_) {}

    return const [
      BudgetModel(id: 1, name: 'Tổng chi tiêu tháng', category: 'Tất cả', limitAmount: 10000000.0),
      BudgetModel(id: 2, name: 'Hạn mức Ăn uống', category: 'Ăn uống', limitAmount: 3000000.0),
      BudgetModel(id: 3, name: 'Hạn mức Mua sắm', category: 'Mua sắm', limitAmount: 2000000.0),
    ];
  }

  // Thêm một hạn mức mới
  Future<int> insertBudget(BudgetModel budget) async {
    final db = await database;
    return await db.insert(tableBudgets, budget.toMap());
  }

  // Cập nhật hạn mức
  Future<int> updateBudget(BudgetModel budget) async {
    final db = await database;
    return await db.update(
      tableBudgets,
      budget.toMap(),
      where: '$colBudgetId = ?',
      whereArgs: [budget.id],
    );
  }

  // Xóa hạn mức
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      tableBudgets,
      where: '$colBudgetId = ?',
      whereArgs: [id],
    );
  }

  // Tính số tiền đã chi tiêu thực tế cho một hạn mức
  Future<double> getSpentForBudget(String category) async {
    final db = await database;
    try {
      if (category == 'Tất cả') {
        final res = await db.rawQuery(
          'SELECT SUM($colAmount) as total FROM $tableTransactions WHERE $colIsExpense = 1',
        );
        return (res.first['total'] as num?)?.toDouble() ?? 0.0;
      } else {
        final res = await db.rawQuery(
          'SELECT SUM($colAmount) as total FROM $tableTransactions WHERE $colIsExpense = 1 AND $colCategory = ?',
          [category],
        );
        return (res.first['total'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (_) {
      return 0.0;
    }
  }

  // Đóng database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
