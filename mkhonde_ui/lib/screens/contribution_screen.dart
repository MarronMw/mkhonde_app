import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';
import '../providers/auth_provider.dart';

class ContributionScreen extends StatelessWidget {
  final int groupId;

  const ContributionScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContributionDialog(context, provider, authProvider),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.contributions.length,
        itemBuilder: (context, index) {
          final contribution = provider.contributions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: Text('MWK ${contribution['amount']}'),
              subtitle: Text('User ${contribution['userId']} - ${contribution['date']}'),
            ),
          );
        },
      ),
    );
  }

  void _showAddContributionDialog(BuildContext context, GroupManagementProvider provider, AuthProvider authProvider) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Contribution'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (MWK)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                await provider.recordContribution(
                  userId: authProvider.currentUser!['id'],
                  groupId: groupId,
                  amount: amount,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}