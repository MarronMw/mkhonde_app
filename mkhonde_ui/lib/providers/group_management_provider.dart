import 'package:flutter/foundation.dart';
import 'package:mkhonde_ui/database/database.dart';

class GroupManagementProvider with ChangeNotifier {
  final AppDatabase _database;
  Map<String, dynamic>? _currentGroup;
  Map<String, dynamic>? _groupRules;
  List<Map<String, dynamic>> _contributions = [];
  List<Map<String, dynamic>> _loans = [];
  List<Map<String, dynamic>> _penalties = [];
  bool _isLoading = false;
  String? _error;

  GroupManagementProvider(this._database);

  Map<String, dynamic>? get currentGroup => _currentGroup;
  Map<String, dynamic>? get groupRules => _groupRules;
  List<Map<String, dynamic>> get contributions => _contributions;
  List<Map<String, dynamic>> get loans => _loans;
  List<Map<String, dynamic>> get penalties => _penalties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGroupData(int groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load group info
      _currentGroup = await _database.getGroupById(groupId);

      // Load group rules
      _groupRules = await _database.getGroupRules(groupId);

      // Load contributions
      _contributions = await _database.getGroupContributions(groupId);

      // Load loans
      _loans = await _database.getGroupLoans(groupId);

      // Load penalties
      _penalties = await _database.getGroupPenalties(groupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setGroupRules({
    required int groupId,
    required double contributionAmount,
    required int contributionFrequency,
    double? penaltyAmount,
    int? penaltyFrequency,
    int maxActiveLoans = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _database.setGroupRules(
        groupId: groupId,
        contributionAmount: contributionAmount,
        contributionFrequency: contributionFrequency,
        penaltyAmount: penaltyAmount,
        penaltyFrequency: penaltyFrequency,
        maxActiveLoans: maxActiveLoans,
      );

      await loadGroupData(groupId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordContribution({
    required int userId,
    required int groupId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _database.recordContribution(
        userId: userId,
        groupId: groupId,
        amount: amount,
      );

      await loadGroupData(groupId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearGroupData() async {
    _currentGroup = null;
    _groupRules = null;
    _contributions = [];
    _loans = [];
    _penalties = [];
    _error = null;
    notifyListeners();
  }

  // Add to GroupManagementProvider
  Future<bool> recordPenaltyPayment({required int penaltyId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _database.recordPenaltyPayment(penaltyId: penaltyId);
      await loadGroupData(_currentGroup!['id']);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestLoan({
    required int userId,
    required int groupId,
    required double amount,
    required double interestRate,
    required int repaymentMonths,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user has active loans
      final userLoans = await _database.getUserLoans(userId);
      final activeLoans = userLoans.where((loan) => loan['status'] == 'approved' && loan['amountPaid'] < loan['amount']).length;

      if (activeLoans >= (_groupRules?['maxActiveLoans'] ?? 1)) {
        _error = 'You have reached your maximum active loans';
        return false;
      }

      // Check if user has met contribution requirements
      final userContributions = await _database.getUserContributions(userId, groupId);
      final totalContributed = userContributions.fold(0.0, (sum, c) => sum + c['amount']);

      if (amount > totalContributed * 2) { // Example rule: can borrow up to 2x total contributions
        _error = 'Loan amount exceeds your contribution limit';
        return false;
      }

      // Create loan request
      await _database.createLoan(
        userId: userId,
        groupId: groupId,
        amount: amount,
        interestRate: interestRate,
        repaymentMonths: repaymentMonths,
      );

      await loadGroupData(groupId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLoan(int loanId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _database.approveLoan(loanId);
      await loadGroupData(_currentGroup!['id']);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to GroupManagementProvider
  List<Map<String, dynamic>> _groupMembers = [];
  List<Map<String, dynamic>> get groupMembers => _groupMembers;

  Future<void> loadGroupMembers(int groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _groupMembers = await _database.getGroupMembers(groupId);

      // Load additional member stats
      for (var member in _groupMembers) {
        final contributions = await _database.getUserContributionsSummary(member['id'], groupId);
        final loans = await _database.getUserLoansSummary(member['id'], groupId);

        member['totalContributed'] = contributions.first['totalContributed'] ?? 0;
        member['contributionCount'] = contributions.first['contributionCount'] ?? 0;
        member['totalBorrowed'] = loans.first['totalBorrowed'] ?? 0;
        member['totalRepaid'] = loans.first['totalRepaid'] ?? 0;
        member['loanCount'] = loans.first['loanCount'] ?? 0;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordLoanPayment({
    required int loanId,
    required double amount,
    bool isPenalty = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _database.recordLoanPayment(
        loanId: loanId,
        amount: amount,
        isPenalty: isPenalty,
      );

      await loadGroupData(_currentGroup!['id']);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordPenalty({
    required int userId,
    required int groupId,
    required double amount,
    required String reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _database.recordPenalty(
        userId: userId,
        groupId: groupId,
        amount: amount,
        reason: reason,
      );

      await loadGroupData(groupId);
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