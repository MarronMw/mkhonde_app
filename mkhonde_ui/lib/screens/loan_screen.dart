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

    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.loans.length,
              itemBuilder: (context, index) {
                final loan = provider.loans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('MWK ${loan['amount']} (${loan['status']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ${loan['userId']}'),
                        Text('Due: ${loan['dueDate']}'),
                        Text('Paid: MWK ${loan['amountPaid'] ?? 0}'),
                      ],
                    ),
                    trailing: isAdmin && loan['status'] == 'pending'
                        ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => provider.approveLoan(loan['id']),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
          if (!isAdmin)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _showRequestLoanDialog(context, provider),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Request New Loan'),
              ),
            ),
        ],
      ),
    );
  }

  void _showRequestLoanDialog(BuildContext context, GroupManagementProvider provider) {
    final amountController = TextEditingController();
    final monthsController = TextEditingController(text: '6');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (MWK)',
              ),
            ),
            TextField(
              controller: monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Repayment Months',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}