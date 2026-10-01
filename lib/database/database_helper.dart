import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static const String _dbName = 'expense_manager.db';
  static const int _dbVersion = 1;

  // Tên bảng và các cột
  static const String tableName = 'transactions';
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colAmount = 'amount';
  static const String colCategory = 'category';
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
    );
  }

  // Khởi tạo bảng dữ liệu SQLite
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle TEXT NOT NULL,
        $colAmount REAL NOT NULL,
        $colCategory TEXT NOT NULL,
        $colDate TEXT NOT NULL,
        $colIsExpense INTEGER NOT NULL,
        $colNote TEXT,
        $colCreatedAt TEXT
      )
    ''');

    // Chèn dữ liệu mẫu ban đầu để app hiển thị đầy đủ ngay lần đầu chạy
    await _insertSampleData(db);
  }

  // Dữ liệu mẫu ban đầu tương thích với giao diện
  Future<void> _insertSampleData(Database db) async {
    final sampleItems = [
      {
        colTitle: 'Ăn trưa',
        colCategory: 'Ăn uống',
        colDate: '03/09/2024',
        colAmount: 50000.0,
        colIsExpense: 1,
        colNote: 'Ăn trưa cùng đồng nghiệp',
        colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        colTitle: 'Xăng xe',
        colCategory: 'Di chuyển',
        colDate: '03/09/2024',
        colAmount: 100000.0,
        colIsExpense: 1,
        colNote: 'Đổ xăng xe máy',
        colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        colTitle: 'Lương tháng 9',
        colCategory: 'Thu nhập',
        colDate: '01/09/2024',
        colAmount: 8000000.0,
        colIsExpense: 0,
        colNote: 'Lương chuyển khoản tháng 9',
        colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        colTitle: 'Mua sắm',
        colCategory: 'Mua sắm',
        colDate: '31/08/2024',
        colAmount: 300000.0,
        colIsExpense: 1,
        colNote: 'Mua đồ dùng cá nhân',
        colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        colTitle: 'Học phí',
        colCategory: 'Giáo dục',
        colDate: '30/08/2024',
        colAmount: 500000.0,
        colIsExpense: 1,
        colNote: 'Đóng học phí khóa học Flutter',
        colCreatedAt: DateTime.now().toIso8601String(),
      },
    ];

    for (final item in sampleItems) {
      await db.insert(tableName, item);
    }
  }

  // ==================== CÁC PHƯƠNG THỨC CRUD ====================

  // 1. CREATE: Thêm giao dịch mới
  Future<int> insert(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert(tableName, transaction.toMap());
  }

  // 2. READ: Lấy tất cả giao dịch (mới nhất lên đầu)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query(tableName, orderBy: '$colId DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Lấy các giao dịch gần đây có giới hạn số lượng (mặc định 5 giao dịch)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final db = await instance.database;
    final result = await db.query(
      tableName,
      orderBy: '$colId DESC',
      limit: limit,
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Lấy giao dịch theo ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
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
      tableName,
      transaction.toMap(),
      where: '$colId = ?',
      whereArgs: [transaction.id],
    );
  }

  // 4. DELETE: Xóa giao dịch theo ID
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // Xóa toàn bộ giao dịch
  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(tableName);
  }

  // ==================== TÍNH TOÁN THỐNG KÊ ====================

  // Tính tổng thu nhập
  Future<double> getTotalIncome() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM($colAmount) as total FROM $tableName WHERE $colIsExpense = 0',
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
      'SELECT SUM($colAmount) as total FROM $tableName WHERE $colIsExpense = 1',
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

  // Đóng database khi không còn sử dụng
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
