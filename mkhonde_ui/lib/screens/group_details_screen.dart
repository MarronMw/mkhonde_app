import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_management_provider.dart';
import 'package:flutter/services.dart';

class GroupDetailsScreen extends StatelessWidget {
  final int groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  Widget buildCardTile(String title, String value, {IconButton? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(60),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white70)),
        trailing: trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupManagementProvider>(context);
    final group = provider.currentGroup;
    final rules = provider.groupRules;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Group Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                buildCardTile(
                  'Group Name',
                  group?['name'] ?? 'N/A',
                ),
                buildCardTile(
                  'Group Code',
                  group?['code'] ?? 'N/A',
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFFFFB703)),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: group?['code'] ?? ''),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group code copied')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Group Rules',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Contribution Amount', style: TextStyle(color: Colors.white)),
                        subtitle: Text('MWK ${rules?['contributionAmount'] ?? '0'}',
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        title: const Text('Contribution Frequency', style: TextStyle(color: Colors.white)),
                        subtitle: Text('Every ${rules?['contributionFrequency'] ?? '1'} months',
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        title: const Text('Penalty Amount', style: TextStyle(color: Colors.white)),
                        subtitle: Text('MWK ${rules?['penaltyAmount'] ?? '0'}',
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        title: const Text('Penalty After', style: TextStyle(color: Colors.white)),
                        subtitle: Text('${rules?['penaltyFrequency'] ?? '0'} days late',
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        title: const Text('Max Active Loans', style: TextStyle(color: Colors.white)),
                        subtitle: Text('${rules?['maxActiveLoans'] ?? '1'} per member',
                            style: const TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
