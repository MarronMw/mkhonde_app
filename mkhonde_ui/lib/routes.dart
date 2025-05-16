import 'package:flutter/material.dart';
import 'package:mkhonde_ui/screens/login_screen.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:mkhonde_ui/screens/group_section_screen.dart';
import 'package:mkhonde_ui/screens/language_selection/language_screen.dart';
import 'package:mkhonde_ui/screens/join_group_screen.dart';
import 'package:mkhonde_ui/screens/group_home_screen.dart';
import 'package:mkhonde_ui/screens/send_money_screen.dart';
import 'package:mkhonde_ui/screens/registration_screen.dart';
import 'package:mkhonde_ui/providers/auth_provider.dart';

class AppRoutes {
  static const String language = '/language';
  static const String register = '/';
  static const String groupSection = '/group';
  static const String joinGroup = '/join';
  static const String groupHome = '/maingroup';
  static const String sendMoney = '/sendMoney';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const LanguageScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (context) => const RegistrationScreen(),
          settings: settings,
        );
      case '/login':
        return _authGuard(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        ),
            context as BuildContext
        );
      case '/dashboard':
        return _authGuard(
          MaterialPageRoute(
            builder: (context) => const LanguageScreen(),
            settings: settings,
          ),
          context as BuildContext,
        );
      case '/group':
        return _authGuard(
          MaterialPageRoute(
            builder: (context) => const GroupSectionScreen(),
            settings: settings,
          ),
          context as BuildContext,
        );
      case '/join':
        return _authGuard(
          MaterialPageRoute(
            builder: (context) => const JoinGroupScreen(),
            settings: settings,
          ),
          context as BuildContext,
        );
      case '/maingroup':
        return _authGuard(
          MaterialPageRoute(
            builder: (context) => const GroupHomeScreen(),
            settings: settings,
          ),
          context as BuildContext,
        );
      case '/sendMoney':
        return _authGuard(
          MaterialPageRoute(
            builder: (context) =>  SendMoneyScreen(),
            settings: settings,
          ),
          context as BuildContext,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Route<dynamic> _authGuard(
      MaterialPageRoute route,
      BuildContext context,
      ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      return MaterialPageRoute(
        builder: (context) => const RegistrationScreen(),
      );
    }

    // Check if user has selected language
    if (authProvider.currentUser?['languageCode'] == null &&
        route.settings.name != '/') {
      return MaterialPageRoute(
        builder: (context) => const LanguageScreen(),
      );
    }

    return route;
  }

  static Map<String, WidgetBuilder> get routes {
    return {
      '/language': (context) => const LanguageScreen(),
      '/': (context) => const RegistrationScreen(),
      '/group': (context) => const GroupSectionScreen(),
      '/join': (context) => const JoinGroupScreen(),
      '/maingroup': (context) => const GroupHomeScreen(),
      '/sendMoney': (context) => SendMoneyScreen(),
      '/login': (context) => LoginScreen(),
    };
  }
}