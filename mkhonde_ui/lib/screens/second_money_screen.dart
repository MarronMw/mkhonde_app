import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/group_management_provider.dart';
// import '../providers/auth_provider.dart';

class SendMoneyScreen extends StatefulWidget {
  final int groupId;

  const SendMoneyScreen({super.key, required this.groupId});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<GroupManagementProvider>(context);
    // final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
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
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  // Implement send money logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Money sent successfully')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Money'),
            ),
          ],
        ),
      ),
    );
  }
}