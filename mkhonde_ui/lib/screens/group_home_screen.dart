import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupHomeScreen extends StatelessWidget {
  const GroupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Your Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildFeatureButtonsGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: const [
          Text(
            'Group Balance',
            style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          SizedBox(height: 8),
          Text(
            'MWK 256,400',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF023047),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButtonsGrid(BuildContext context) {
    final features = [
      {'icon': FontAwesomeIcons.paperPlane, 'label': 'Send Money'},
      {'icon': FontAwesomeIcons.handHoldingDollar, 'label': 'Withdraw'},
      {'icon': FontAwesomeIcons.receipt, 'label': 'Transactions'},
      {'icon': FontAwesomeIcons.usersGear, 'label': 'Group Details'},
    ];

    return GridView.builder(
      shrinkWrap: true,
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
          onTap: () {
            switch (label) {
              case 'Send Money':
                Navigator.pushNamed(context, '/sendMoney');
                break;
              case 'Withdraw':
                Navigator.pushNamed(context, '/withdraw');
                break;
              case 'Transactions':
                Navigator.pushNamed(context, '/transactions');
                break;
              case 'Group Details':
                Navigator.pushNamed(context, '/groupDetails');
                break;
            }
          },
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
}
