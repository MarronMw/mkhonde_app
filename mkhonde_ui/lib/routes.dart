import 'package:flutter/material.dart';
import 'package:mkhonde/screens/group_section_screen.dart';
import 'screens/language_selection/language_screen.dart';
import 'package:mkhonde/screens/join_group_screen.dart';
// other imports...

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LanguageScreen(),
  '/group': (context) => const GroupSectionScreen(),
  '/join': (context) => const JoinGroupScreen(),
};
