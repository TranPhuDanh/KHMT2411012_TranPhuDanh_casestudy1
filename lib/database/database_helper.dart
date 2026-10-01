import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static const String _dbName = 'expense_manager.db';
  static const int _dbVersion = 3;

  // Bảng Danh mục (Categories)
  static const String tableCategories = 'categories';
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatIcon = 'icon';
  static const String colCatIsExpense = 'is_expense';

  // Bảng Giao dịch (Transactions)
  static const String tableTransactions = 'transactions';
  static const String colId = 'id';
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
  }

  // Bật hỗ trợ Foreign Key trong SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Khởi tạo các bảng trong Database
  Future<void> _createDB(Database db, int version) async {
    // 1. Tạo bảng Danh mục (Categories)
    await db.execute('''
      CREATE TABLE $tableCategories (
        $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCatName TEXT NOT NULL UNIQUE,
        $colCatIcon TEXT NOT NULL,
        $colCatIsExpense INTEGER NOT NULL
      )
    ''');

    // 2. Tạo bảng Giao dịch (Transactions) có liên kết Khóa ngoại Foreign Key tới Categories
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
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

    // 3. Khởi tạo dữ liệu mẫu ban đầu
    await _insertSampleCategories(db);
    await _insertSampleTransactions(db);
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

  // Đóng database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
