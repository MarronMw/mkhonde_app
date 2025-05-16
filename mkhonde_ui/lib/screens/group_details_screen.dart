import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';

class GroupDetailsScreen extends StatelessWidget {
  final int groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);
    final group = provider.currentGroup;
    final rules = provider.groupRules;

    return Scaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text('Group Name'),
                subtitle: Text(group?['name'] ?? 'N/A'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Group Code'),
                subtitle: Text(group?['code'] ?? 'N/A'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // Implement copy to clipboard
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Group Rules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Contribution Amount'),
                    subtitle: Text('MWK ${rules?['contributionAmount'] ?? '0'}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Contribution Frequency'),
                    subtitle: Text('Every ${rules?['contributionFrequency'] ?? '1'} months'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Penalty Amount'),
                    subtitle: Text('MWK ${rules?['penaltyAmount'] ?? '0'}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Penalty After'),
                    subtitle: Text('${rules?['penaltyFrequency'] ?? '0'} days late'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Max Active Loans'),
                    subtitle: Text('${rules?['maxActiveLoans'] ?? '1'} per member'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}