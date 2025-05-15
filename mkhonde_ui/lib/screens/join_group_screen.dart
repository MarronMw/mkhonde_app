import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JoinGroupScreen extends StatelessWidget {
  const JoinGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF006D77),
        //  Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: const Text(
          'Join Group',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            margin: const EdgeInsets.only(top: 0, bottom: 40),
            width: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [


                // Name input
                _buildInputField(
                  icon: FontAwesomeIcons.user,
                  hintText: 'Your Name',
                ),

                // Phone input
                _buildInputField(
                  icon: FontAwesomeIcons.phone,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),

                // Group Code input
                _buildInputField(
                  icon: FontAwesomeIcons.key,
                  hintText: 'Group Code',
                ),



                ElevatedButton(
                  onPressed: () {
                    // Normal push so user can come back if needed
                    Navigator.pushNamed(context, '/maingroup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 350),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
