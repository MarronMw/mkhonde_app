import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _groupCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            margin: const EdgeInsets.only(top: 60, bottom: 40),
            width: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Join Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (groupProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        groupProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Group Code input
                  TextFormField(
                    controller: _groupCodeController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(FontAwesomeIcons.key, color: Colors.grey),
                      hintText: 'Group Code',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter group code';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: groupProvider.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        groupProvider.clearError();
                        final success =
                        await groupProvider.joinGroup(
                          userId: authProvider.currentUser!['id'],
                          groupCode: _groupCodeController.text.trim(),
                        );

                        if (success && mounted) {
                          Navigator.pushReplacementNamed(
                              context, '/maingroup');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: groupProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Join',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}