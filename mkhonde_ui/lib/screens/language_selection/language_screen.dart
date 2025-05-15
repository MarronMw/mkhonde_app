import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome To Mkhonde Wallet',
        style: TextStyle(
            color: Colors.white,
        ),),
        backgroundColor: const Color(0xFF83C5BE),
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
        child: Center(
          child: Container(
            // width: 400,
            // padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.0), // transparent for visual clarity
              // borderRadius: BorderRadius.circular(16),
              boxShadow: [

              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const SizedBox(height: 40),
                const Text(
                  'Select Your Language',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: ['English', 'Chichewa', 'Tumbuka', 'Yao']
                      .map(
                        (lang) => Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/group');
                        },
                        child: Text(
                          lang,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'You can change the language later in settings.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
