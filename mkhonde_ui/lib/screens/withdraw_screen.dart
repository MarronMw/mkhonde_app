import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';

class WithdrawScreen extends StatefulWidget {
  final int groupId;

  const WithdrawScreen({super.key, required this.groupId});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (MWK)',
                prefixText: 'MWK ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Withdrawal',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  // Implement withdraw logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawal request submitted')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Request Withdrawal'),
            ),
          ],
        ),
      ),
    );
  }
}