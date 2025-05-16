import 'package:flutter/foundation.dart';
import 'package:mkhonde_ui/database/database.dart';

class AuthProvider with ChangeNotifier {
  final AppDatabase _database;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._database);

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _database.getLoggedInUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await _database.getUserByPhone(phone);
      if (existingUser != null) {
        _error = 'User already registered';
        return false;
      }

      // Insert new user
      final userId = await _database.insertUser({
        'name': name,
        'phone': phone,
        'password': password, // Note: In production, hash the password!
      });

      // Set as logged in
      await _database.setLoggedInUser(userId);
      await initialize(); // Refresh current user

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _database.getUserByPhone(phone);

      if (user == null || user['password'] != password) {
        _error = 'Invalid phone number or password';
        return false;
      }

      await _database.setLoggedInUser(user['id']);
      _currentUser = user;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _database.setLoggedInUser(-1); // Reset logged in status
      }
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    if (_currentUser == null) return;

    try {
      await _database.updateUserLanguage(_currentUser!['id'], languageCode);
      await initialize();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}