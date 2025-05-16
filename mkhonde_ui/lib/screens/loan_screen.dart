import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';
import '../providers/auth_provider.dart';

class LoanScreen extends StatelessWidget {
  final int groupId;

  const LoanScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = provider.currentGroup?['createdBy'] == authProvider.currentUser?['id'];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Loans',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            Expanded(
              child: provider.loans.isEmpty
                  ? const Center(
                child: Text(
                  'No loans available.',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.loans.length,
                itemBuilder: (context, index) {
                  final loan = provider.loans[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MWK ${loan['amount']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isAdmin && loan['status'] == 'pending')
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Color(0xFFFFB703)),
                                onPressed: () => provider.approveLoan(loan['id']),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Status: ${loan['status']}', style: TextStyle(color: Colors.grey[300])),
                        Text('User ID: ${loan['userId']}', style: TextStyle(color: Colors.grey[300])),
                        Text('Due: ${loan['dueDate']}', style: TextStyle(color: Colors.grey[300])),
                        Text('Paid: MWK ${loan['amountPaid'] ?? 0}', style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showRequestLoanDialog(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('Request New Loan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRequestLoanDialog(BuildContext context, GroupManagementProvider provider) {
    final amountController = TextEditingController();
    final monthsController = TextEditingController(text: '6');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF006D77),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request Loan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (MWK)',
                labelStyle: TextStyle(color: Colors.grey[300]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: monthsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Repayment Months',
                labelStyle: TextStyle(color: Colors.grey[300]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final months = int.tryParse(monthsController.text) ?? 6;

              if (amount > 0 && months > 0) {
                await provider.requestLoan(
                  userId: Provider.of<AuthProvider>(context, listen: false).currentUser!['id'],
                  groupId: groupId,
                  amount: amount,
                  interestRate: 10.0,
                  repaymentMonths: months,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB703),
              foregroundColor: Colors.black,
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
