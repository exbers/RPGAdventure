import 'package:flutter/material.dart';

import '../features/main_menu/presentation/main_menu_screen.dart';
import 'game_theme.dart';

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Space O',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.light,
      darkTheme: GameTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainMenuScreen(),
    );
  }
}
