import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SendMoneyScreen extends StatefulWidget {
  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Payment Option',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF83C5BE),


      ),
      backgroundColor: Color(0xFFE7F0EE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Container(
            height: 600,
            width: 360,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                _buildInputField(),
                _buildPaymentOptions(),
                _buildPayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter amount',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _paymentOption('assets/mpamba.png', 'Mpamba (TNM)'),
          _paymentOption('assets/airtel.png', 'Airtel Money'),
          _paymentOption('assets/nb.jpg', 'National Bank of Malawi'),
          _paymentOption('assets/std.jpg', 'Standard Bank'),
        ],
      ),
    );
  }

  Widget _paymentOption(String iconPath, String label) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFF0F4F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 24, width: 24),
          SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: ElevatedButton(
        onPressed: () {
          // Handle proceed logic here
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 100),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        child: Text(
          'Proceed to Pay',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
