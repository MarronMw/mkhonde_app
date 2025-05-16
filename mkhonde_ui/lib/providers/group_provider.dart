import 'package:flutter/foundation.dart';
import 'package:mkhonde_ui/database/database.dart';

class GroupProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Map<String, dynamic>> _userGroups = [];
  bool _isLoading = false;
  String? _error;

  GroupProvider(this._database);

  List<Map<String, dynamic>> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserGroups(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userGroups = await _database.getUserGroups(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroup({
    required int userId,
    required String groupCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find group by code
      final group = await _database.getGroupByCode(groupCode);
      if (group == null) {
        _error = 'Group not found';
        return false;
      }

      // Check if already in group
      final userGroups = await _database.getUserGroups(userId);
      if (userGroups.any((g) => g['id'] == group['id'])) {
        _error = 'You are already in this group';
        return false;
      }

      // Join group
      await _database.joinGroup(userId, group['id']);
      await loadUserGroups(userId); // Refresh groups list

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGroup({
    required int userId,
    required String name,
    required String code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if group code exists
      final existingGroup = await _database.getGroupByCode(code);
      if (existingGroup != null) {
        _error = 'Group code already exists';
        return false;
      }

      // Create new group
      final groupId = await _database.createGroup({
        'name': name,
        'code': code,
        'createdBy': userId,
      });

      // Automatically join the created group
      await _database.joinGroup(userId, groupId);
      await loadUserGroups(userId); // Refresh groups list

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}