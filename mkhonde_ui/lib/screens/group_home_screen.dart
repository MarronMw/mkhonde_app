import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mkhonde_ui/screens/penalties_screen.dart';
import 'package:mkhonde_ui/screens/second_money_screen.dart';
import 'package:mkhonde_ui/screens/transaction_screen.dart';
import 'package:mkhonde_ui/screens/withdraw_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_management_provider.dart';
import 'contribution_screen.dart';
import 'group_details_screen.dart';
import 'loan_screen.dart';

class GroupHomeScreen extends StatefulWidget {
  final int? groupId; // Keep as nullable

  const GroupHomeScreen({super.key, this.groupId});

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GroupManagementProvider>(context, listen: false);
      if (widget.groupId != null) {
        provider.loadGroupData(widget.groupId!); // Use ! after null check
      } else {
        // Optionally handle null groupId (e.g., show default data or error)
        // Assuming a method to reset provider state
        // provider.error; // This was incorrect; replace with appropriate handling
        provider.clearGroupData(); // Hypothetical method to clear provider state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final groupProvider = context.watch<GroupManagementProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text(groupProvider.currentGroup?['name'] ?? 'Group'),
        actions: [
          if (groupProvider.currentGroup?['createdBy'] == authProvider.currentUser?['id'] &&
              widget.groupId != null) // Null check for settings
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showGroupSettings(context, groupProvider),
            ),
        ],
      ),
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
        child: SingleChildScrollView( // Wrap content in SingleChildScrollView
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (groupProvider.isLoading && groupProvider.currentGroup == null)
                    const Center(child: CircularProgressIndicator())
                  else if (widget.groupId == null) ...[
                    // Display message when groupId is null
                    const Center(
                      child: Text(
                        'No group selected. Please select a group.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ] else ...[
                    _buildBalanceCard(groupProvider),
                    const SizedBox(height: 24),
                    _buildFeatureButtonsGrid(context, groupProvider),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(GroupManagementProvider provider) {
    final totalContributions = provider.contributions.fold(
        0.0, (sum, contribution) => sum + contribution['amount']);

    final totalLoans = provider.loans
        .where((loan) => loan['status'] == 'approved')
        .fold(0.0, (sum, loan) => sum + loan['amount']);

    final totalRepayments = provider.loans
        .where((loan) => loan['status'] == 'approved')
        .fold(0.0, (sum, loan) => sum + (loan['amountPaid'] ?? 0));

    final availableBalance = totalContributions - (totalLoans - totalRepayments);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          const Text(
            'Group Balance',
            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 8),
          Text(
            'MWK ${availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF023047),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceDetail('Contributions', totalContributions),
              _buildBalanceDetail('Loans', totalLoans),
              _buildBalanceDetail('Repayments', totalRepayments),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
        ),
        Text(
          'MWK ${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeatureButtonsGrid(
      BuildContext context, GroupManagementProvider provider) {
    final features = [
      {
        'icon': FontAwesomeIcons.paperPlane,
        'label': 'Send Money',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SendMoneyScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.handHoldingDollar,
        'label': 'Withdraw',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WithdrawScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.receipt,
        'label': 'Transactions',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionsScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.usersGear,
        'label': 'Group Details',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailsScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.handHoldingHeart,
        'label': 'Contributions',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContributionScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.moneyBillWave,
        'label': 'Loans',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoanScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.triangleExclamation,
        'label': 'Penalties',
        'onTap': widget.groupId != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PenaltiesScreen(groupId: widget.groupId!),
          ),
        )
            : () => _showNullGroupIdError(context),
      },
      {
        'icon': FontAwesomeIcons.userGroup,
        'label': 'Members',
        'onTap': () => _showGroupMembers(context, provider),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = features[index];
        final label = item['label'] as String;

        return GestureDetector(
          onTap: item['onTap'] as void Function()?,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  item['icon'] as IconData,
                  size: 22,
                  color: const Color(0xFFFB8500),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF023047),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNullGroupIdError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No group selected. Please select a group.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showGroupSettings(
      BuildContext context, GroupManagementProvider provider) {
    if (widget.groupId == null) {
      _showNullGroupIdError(context);
      return;
    }

    final rules = provider.groupRules;
    final contributionController = TextEditingController(
        text: rules?['contributionAmount']?.toString() ?? '');
    final frequencyController = TextEditingController(
        text: rules?['contributionFrequency']?.toString() ?? '');
    final penaltyController = TextEditingController(
        text: rules?['penaltyAmount']?.toString() ?? '');
    final penaltyDaysController = TextEditingController(
        text: rules?['penaltyFrequency']?.toString() ?? '');
    final maxLoansController = TextEditingController(
        text: rules?['maxActiveLoans']?.toString() ?? '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Rules'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contributionController,
                decoration: const InputDecoration(
                  labelText: 'Contribution Amount (MWK)',
                  hintText: 'e.g. 10000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency (months)',
                  hintText: 'e.g. 1 (for monthly)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: penaltyController,
                decoration: const InputDecoration(
                  labelText: 'Penalty Amount (MWK)',
                  hintText: 'e.g. 2000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: penaltyDaysController,
                decoration: const InputDecoration(
                  labelText: 'Penalty After (days)',
                  hintText: 'e.g. 7 (for 1 week)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxLoansController,
                decoration: const InputDecoration(
                  labelText: 'Max Active Loans',
                  hintText: 'e.g. 1',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final contribution = double.tryParse(contributionController.text) ?? 0;
              final frequency = int.tryParse(frequencyController.text) ?? 1;
              final penalty = double.tryParse(penaltyController.text);
              final penaltyDays = int.tryParse(penaltyDaysController.text);
              final maxLoans = int.tryParse(maxLoansController.text) ?? 1;

              await provider.setGroupRules(
                groupId: widget.groupId!, // Safe after null check
                contributionAmount: contribution,
                contributionFrequency: frequency,
                penaltyAmount: penalty,
                penaltyFrequency: penaltyDays,
                maxActiveLoans: maxLoans,
              );

              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Rules'),
          ),
        ],
      ),
    );
  }

  void _showGroupMembers(BuildContext context, GroupManagementProvider provider) {
    // Load members if not already loaded and groupId is not null
    if (provider.groupMembers.isEmpty && widget.groupId != null) {
      provider.loadGroupMembers(widget.groupId!);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: provider.isLoading && provider.groupMembers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.groupMembers.isEmpty
              ? const Center(child: Text('No members found'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: provider.groupMembers.length,
            itemBuilder: (context, index) {
              final member = provider.groupMembers[index];
              return _buildMemberCard(member);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    // Provide default values for nullable doubles
    final totalContributed = (member['totalContributed'] as num?)?.toDouble() ?? 0.0;
    final totalBorrowed = (member['totalBorrowed'] as num?)?.toDouble() ?? 0.0;
    final totalRepaid = (member['totalRepaid'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member['name']?.toString() ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${member['phone']?.toString() ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMemberStat('Contributions', member['contributionCount'], totalContributed),
                _buildMemberStat('Loans', member['loanCount'], totalBorrowed),
                _buildMemberStat('Repaid', null, totalRepaid),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStat(String label, int? count, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (count != null)
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        Text(
          'MWK ${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}