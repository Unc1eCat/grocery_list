import 'package:flutter/material.dart';
import 'package:grocery_list/screens/tabs_screen.dart';

void main() {
  runApp(TheApp());
}

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        // tabBarTheme: TabBarTheme(),
        bottomAppBarColor: Color(0xFF081524),
        scaffoldBackgroundColor: Color(0xFF08111c),
        // canvasColor: Colors.red,
        backgroundColor: Color(0xFF1E1E1E),
      ),
      routes: {
        "/": (ctx) => TabsScreen(),
      },
    );
  }
}
