import 'package:flutter/material.dart';
import 'package:mkhonde_ui/database/database.dart';
import 'package:mkhonde_ui/providers/auth_provider.dart';
import 'package:mkhonde_ui/providers/group_provider.dart';
import 'package:provider/provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => AuthProvider(database)..initialize(),
      ),
      ChangeNotifierProvider(
        create: (context) => GroupProvider(database),
      ),
    ],
    child: const MyGroupApp(),
    )
  );

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
      routes: AppRoutes.routes,
    );
  }
}
