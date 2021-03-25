import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/screens/list_item_edit_screen.dart';
import 'package:grocery_list/screens/tabs_screen.dart';
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

  static Future<void> fetchAppDocDirectory() async {
    appDocDirectory = await pp.getApplicationDocumentsDirectory();
    groceryItemsFile = await File(path.join(appDocDirectory.absolute.path, "grocery_item.json")).create(); // TODO: Rename the file to "grocery_items.json"
    groceryPrototypesFile = await File(path.join(appDocDirectory.absolute.path, "grocery_prototypes.json")).create();
  }
}

class _TheAppState extends State<TheApp> {
  GroceryListBloc groceryListBloc;

  @override
  void initState() {
    groceryListBloc = GroceryListBloc(<GroceryItem>[]);

    TheApp.fetchAppDocDirectory().then((value) => groceryListBloc.fetchItems());

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroceryListBloc>(
      create: (context) => groceryListBloc,
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          // tabBarTheme: TabBarTheme(),
          primaryColor: Colors.purple,
          bottomAppBarColor: Color(0xFF081524),
          scaffoldBackgroundColor: Color(0xFF08111c),
          // canvasColor: Colors.red,
          backgroundColor: Color(0xFF1E1E1E),
          textTheme: TextTheme(
            caption: TextStyle(
              fontSize: 18,
            ),
            headline6: TextStyle(
              fontSize: 20,
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
