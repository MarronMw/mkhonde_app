import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;


  factory AppDatabase() => _instance;

  AppDatabase._internal();


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'village_bank.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        languageCode TEXT DEFAULT 'en',
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        createdBy INTEGER,
        FOREIGN KEY(createdBy) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_groups(
        userId INTEGER,
        groupId INTEGER,
        joinedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(userId, groupId),
        FOREIGN KEY(userId) REFERENCES users(id),
        FOREIGN KEY(groupId) REFERENCES groups(id)
      )
    ''');
    await db.execute('''
    CREATE TABLE group_rules(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      groupId INTEGER NOT NULL,
      contributionAmount REAL NOT NULL,
      contributionFrequency INTEGER NOT NULL, -- in months
      penaltyAmount REAL,
      penaltyFrequency INTEGER, -- in days
      maxActiveLoans INTEGER DEFAULT 1,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(groupId) REFERENCES groups(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE contributions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      groupId INTEGER NOT NULL,
      amount REAL NOT NULL,
      date TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(userId) REFERENCES users(id),
      FOREIGN KEY(groupId) REFERENCES groups(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE loans(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      groupId INTEGER NOT NULL,
      amount REAL NOT NULL,
      interestRate REAL NOT NULL,
      status TEXT NOT NULL, -- pending, approved, rejected, paid
      dateApproved TEXT,
      dueDate TEXT,
      amountPaid REAL DEFAULT 0,
      FOREIGN KEY(userId) REFERENCES users(id),
      FOREIGN KEY(groupId) REFERENCES groups(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE loan_payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      loanId INTEGER NOT NULL,
      amount REAL NOT NULL,
      date TEXT DEFAULT CURRENT_TIMESTAMP,
      isPenalty INTEGER DEFAULT 0,
      FOREIGN KEY(loanId) REFERENCES loans(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE penalties(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      groupId INTEGER NOT NULL,
      amount REAL NOT NULL,
      reason TEXT NOT NULL,
      date TEXT DEFAULT CURRENT_TIMESTAMP,
      isPaid INTEGER DEFAULT 0,
      FOREIGN KEY(userId) REFERENCES users(id),
      FOREIGN KEY(groupId) REFERENCES groups(id)
    )
  ''');
  }

  // User CRUD operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserLanguage(int userId, String languageCode) async {
    final db = await database;
    await db.update(
      'users',
      {'languageCode': languageCode},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> setLoggedInUser(int userId) async {
    final db = await database;
    // First reset all users to logged out state
    await db.update('users', {'isLoggedIn': 0});
    // Then set the current user as logged in
    await db.update(
      'users',
      {'isLoggedIn': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'isLoggedIn = 1',
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Add to AppDatabase class
  Future<int> createGroup(Map<String, dynamic> group) async {
    final db = await database;
    return await db.insert('groups', group);
  }

  Future<Map<String, dynamic>?> getGroupByCode(String code) async {
    final db = await database;
    final result = await db.query(
      'groups',
      where: 'code = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> joinGroup(int userId, int groupId) async {
    final db = await database;
    return await db.insert('user_groups', {
      'userId': userId,
      'groupId': groupId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserGroups(int userId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT groups.* FROM groups
    JOIN user_groups ON groups.id = user_groups.groupId
    WHERE user_groups.userId = ?
  ''', [userId]);
  }
  // Group rules methods
  Future<Map<String, dynamic>?> getGroupRules(int groupId) async {
    final db = await database;
    final result = await db.query(
      'group_rules',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> setGroupRules({
    required int groupId,
    required double contributionAmount,
    required int contributionFrequency,
    double? penaltyAmount,
    int? penaltyFrequency,
    int maxActiveLoans = 1,
  }) async {
    final db = await database;

    // Check if rules exist
    final existingRules = await getGroupRules(groupId);

    if (existingRules != null) {
      return await db.update(
        'group_rules',
        {
          'contributionAmount': contributionAmount,
          'contributionFrequency': contributionFrequency,
          'penaltyAmount': penaltyAmount,
          'penaltyFrequency': penaltyFrequency,
          'maxActiveLoans': maxActiveLoans,
        },
        where: 'groupId = ?',
        whereArgs: [groupId],
      );
    } else {
      return await db.insert('group_rules', {
        'groupId': groupId,
        'contributionAmount': contributionAmount,
        'contributionFrequency': contributionFrequency,
        'penaltyAmount': penaltyAmount,
        'penaltyFrequency': penaltyFrequency,
        'maxActiveLoans': maxActiveLoans,
      });
    }
  }

  Future<Map<String, dynamic>?> getGroupById(int groupId) async {
    final db = await database;
    final result = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );
    return result.isNotEmpty ? result.first : null;
  }

// Contribution methods
  Future<int> recordContribution({
    required int userId,
    required int groupId,
    required double amount,
  }) async {
    final db = await database;
    return await db.insert('contributions', {
      'userId': userId,
      'groupId': groupId,
      'amount': amount,
    });
  }

  Future<List<Map<String, dynamic>>> getGroupContributions(int groupId) async {
    final db = await database;
    return await db.query(
      'contributions',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserContributions(int userId, int groupId) async {
    final db = await database;
    return await db.query(
      'contributions',
      where: 'userId = ? AND groupId = ?',
      whereArgs: [userId, groupId],
    );
  }

// Loan methods
  Future<int> createLoan({
    required int userId,
    required int groupId,
    required double amount,
    required double interestRate,
    required int repaymentMonths,
  }) async {
    final db = await database;

    final dueDate = DateTime.now().add(Duration(days: 30 * repaymentMonths)).toIso8601String();

    return await db.insert('loans', {
      'userId': userId,
      'groupId': groupId,
      'amount': amount,
      'interestRate': interestRate,
      'status': 'pending',
      'dueDate': dueDate,
    });
  }

  Future<int> approveLoan(int loanId) async {
    final db = await database;
    return await db.update(
      'loans',
      {
        'status': 'approved',
        'dateApproved': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }

  Future<List<Map<String, dynamic>>> getGroupLoans(int groupId) async {
    final db = await database;
    return await db.query(
      'loans',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'dateApproved DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserLoans(int userId) async {
    final db = await database;
    return await db.query(
      'loans',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> recordLoanPayment({
    required int loanId,
    required double amount,
    bool isPenalty = false,
  }) async {
    final db = await database;

    // Record payment
    await db.insert('loan_payments', {
      'loanId': loanId,
      'amount': amount,
      'isPenalty': isPenalty ? 1 : 0,
    });

    // Update loan amount paid
    final payments = await db.query(
      'loan_payments',
      where: 'loanId = ?',
      whereArgs: [loanId],
    );

    final totalPaid = payments.fold<double>(0.0, (sum, payment) {
      final amount = payment['amount'];
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });

    final loan = (await db.query('loans', where: 'id = ?', whereArgs: [loanId])).first;
    final loanAmount = loan['amount'];
    final amountValue = loanAmount is num ? loanAmount.toDouble() : 0.0;

    final status = totalPaid >= amountValue ? 'paid' : 'approved';

    return await db.update(
      'loans',
      {
        'amountPaid': totalPaid,
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [loanId],
    );

  }

// Penalty methods
  Future<int> recordPenalty({
    required int userId,
    required int groupId,
    required double amount,
    required String reason,
  }) async {
    final db = await database;
    return await db.insert('penalties', {
      'userId': userId,
      'groupId': groupId,
      'amount': amount,
      'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> getGroupPenalties(int groupId) async {
    final db = await database;
    return await db.query(
      'penalties',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserPenalties(int userId, int groupId) async {
    final db = await database;
    return await db.query(
      'penalties',
      where: 'userId = ? AND groupId = ?',
      whereArgs: [userId, groupId],
    );
  }

  // Add to AppDatabase class
  Future<int> recordPenaltyPayment({required int penaltyId}) async {
    final db = await database;
    return await db.update(
      'penalties',
      {'isPaid': 1},
      where: 'id = ?',
      whereArgs: [penaltyId],
    );
  }
// Add to AppDatabase class
  Future<List<Map<String, dynamic>>> getGroupMembers(int groupId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT users.id, users.name, users.phone 
    FROM users
    JOIN user_groups ON users.id = user_groups.userId
    WHERE user_groups.groupId = ?
    ORDER BY users.name ASC
  ''', [groupId]);
  }

  Future<List<Map<String, dynamic>>> getUserContributionsSummary(int userId, int groupId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      SUM(amount) as totalContributed,
      COUNT(*) as contributionCount
    FROM contributions
    WHERE userId = ? AND groupId = ?
  ''', [userId, groupId]);
  }

  Future<List<Map<String, dynamic>>> getUserLoansSummary(int userId, int groupId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      SUM(amount) as totalBorrowed,
      SUM(amountPaid) as totalRepaid,
      COUNT(*) as loanCount
    FROM loans
    WHERE userId = ? AND groupId = ?
  ''', [userId, groupId]);
  }

}

