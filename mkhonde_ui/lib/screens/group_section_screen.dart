import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupSectionScreen extends StatelessWidget {
  const GroupSectionScreen({super.key});

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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Group Section',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(),
                const SizedBox(height: 24),
                _buildButtonsRow(context),
                const SizedBox(height: 16),
                const Text(
                  'Your Active Groups:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGroupList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: FaIcon(FontAwesomeIcons.idBadge, color: Colors.grey[600]),
          ),
          hintText: 'Enter Group',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/join');
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
            label: const Text('Join Group'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: const Color(0xFFFFB703),
              foregroundColor: Colors.white,
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Placeholder for create group action
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: const Color(0xFFFFB703),
              foregroundColor: Colors.white,
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList() {
    final groups = ['Anzathu', 'Banja', 'Abwenzi', 'Akatswiri', 'Moyo'];

    return Column(
      children: groups.map((name) => _buildGroupItem(name)).toList(),
    );
  }

  Widget _buildGroupItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.users, color: Color(0xFF006D77), size: 20),
              const SizedBox(width: 12),
              Text(
                name.toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
              ),
            ],
          ),
          const FaIcon(FontAwesomeIcons.chevronRight, size: 18, color: Color(0xFF999999)),
        ],
      ),
    );
  }
}
