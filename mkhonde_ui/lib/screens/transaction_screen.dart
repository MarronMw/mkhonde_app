import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';

class TransactionsScreen extends StatelessWidget {
  final int groupId;

  const TransactionsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.contributions.length + provider.loans.length,
        itemBuilder: (context, index) {
          if (index < provider.contributions.length) {
            final contribution = provider.contributions[index];
            return ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: Text('Contribution: MWK ${contribution['amount']}'),
              subtitle: Text('User ${contribution['userId']} - ${contribution['date']}'),
            );
          } else {
            final loanIndex = index - provider.contributions.length;
            final loan = provider.loans[loanIndex];
            return ListTile(
              leading: Icon(Icons.money_off, color: loan['status'] == 'approved' ? Colors.red : Colors.orange),
              title: Text('Loan: MWK ${loan['amount']} (${loan['status']})'),
              subtitle: Text('User ${loan['userId']} - Due: ${loan['dueDate']}'),
            );
          }
        },
      ),
    );
  }
}