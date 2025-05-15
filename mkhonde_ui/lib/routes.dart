import 'package:flutter/material.dart';
import 'package:mkhonde_ui/screens/group_section_screen.dart';
import 'screens/language_selection/language_screen.dart';
import 'package:mkhonde_ui/screens/join_group_screen.dart';
import 'package:mkhonde_ui/screens/group_home_screen.dart';
// other imports...

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LanguageScreen(),
  '/group': (context) => const GroupSectionScreen(),
  '/join': (context) => const JoinGroupScreen(),
  '/maingroup': (context) => GroupHomeScreen(),
};
