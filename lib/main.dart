import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/screens/list_item_edit_screen.dart';
import 'package:grocery_list/screens/tabs_screen.dart';
import 'package:grocery_list/utils/modeling_utils.dart';
import 'package:grocery_list/utils/scroll_behavior.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as path;

import 'bloc/grocery_list_bloc.dart';
import 'models/grocery_item.dart';

void main() {
  runApp(TheApp());
}

class TheApp extends StatefulWidget {
  @override
  _TheAppState createState() => _TheAppState();

  static Directory appDocDirectory;
  static File groceryItemsFile;
  static File groceryPrototypesFile;
}

class _TheAppState extends State<TheApp> {
  GroceryListBloc groceryListBloc;

  @override
  void initState() {
    groceryListBloc = GroceryListBloc(
        presetTagColors: getShadesOfMaterialColors(
            [Colors.red, Colors.indigo, Colors.amber, Colors.lightGreen, Colors.lightBlue, Colors.teal, Colors.pink, Colors.deepOrange], {200, 500, 800}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroceryListBloc>(
      create: (context) => groceryListBloc,
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // tabBarTheme: TabBarTheme(),
          primaryColor: Colors.purple,
          bottomAppBarColor: Color(0xFF081524),
          scaffoldBackgroundColor: Color(0xFF11181F),
          canvasColor: Color(0xFF12161F),
          cardColor: Color(0xFF12161D),
          // canvasColor: Colors.red,
          backgroundColor: Color(0xFF1E1E1E),
          textTheme: TextTheme(
            caption: TextStyle(
              fontSize: 17,
            ),
            headline6: TextStyle(
              fontSize: 20,
              // fontWeight: FontWeight.w400,
            ),
            headline5: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
            headline4: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w500,
            ),
            headline3: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        routes: {
          "/": (ctx) => TabsScreen(),
          // ListItemEditScreen.routeName: (_) => ListItemEditScreen(),
        },
      ),
    );
  }
}
