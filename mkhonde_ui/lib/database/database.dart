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

}

