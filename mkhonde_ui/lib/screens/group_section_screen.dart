import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import 'group_home_screen.dart';

class GroupSectionScreen extends StatefulWidget {
  const GroupSectionScreen({super.key});

  @override
  State<GroupSectionScreen> createState() => _GroupSectionScreenState();
}

class _GroupSectionScreenState extends State<GroupSectionScreen> {
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.loadUserGroups(authProvider.currentUser!['id']);
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

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
                _buildGroupInput(),
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
                _buildGroupList(groupProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: TextField(
        controller: _groupCodeController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: FaIcon(FontAwesomeIcons.idBadge, color: Colors.grey[600]),
          ),
          hintText: 'Enter Group Code',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
            onPressed: () => _showCreateGroupDialog(context, authProvider, groupProvider),
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

  void _showCreateGroupDialog(BuildContext context, AuthProvider authProvider, GroupProvider groupProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. Anzathu',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _groupCodeController,
              decoration: const InputDecoration(
                labelText: 'Group Code',
                hintText: 'Unique code for members to join',
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
              if (_groupNameController.text.isNotEmpty &&
                  _groupCodeController.text.isNotEmpty) {
                Navigator.pop(context);
                final success = await groupProvider.createGroup(
                  userId: authProvider.currentUser!['id'],
                  name: _groupNameController.text,
                  code: _groupCodeController.text,
                );

                if (success && mounted) {
                  Navigator.pushReplacementNamed(context, '/maingroup');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(GroupProvider groupProvider) {
    if (groupProvider.isLoading && groupProvider.userGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groupProvider.userGroups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'You are not in any groups yet',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: groupProvider.userGroups.map((group) => _buildGroupItem(group)).toList(),
    );
  }

  Widget _buildGroupItem(Map<String, dynamic> group) {
    return GestureDetector(
      onTap:  () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupHomeScreen(groupId: group['id']),
          ),
        );
      },
      child: Container(
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
                  group['name'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
                ),
              ],
            ),
            const FaIcon(FontAwesomeIcons.chevronRight, size: 18, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }
}