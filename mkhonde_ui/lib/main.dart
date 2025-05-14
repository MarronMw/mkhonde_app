import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(const MyGroupApp());
}

class MyGroupApp extends StatelessWidget {
  const MyGroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mkhonde Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
