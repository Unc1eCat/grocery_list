import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  GroceryListBloc groceryListBloc;

  @override
  void initState() {
    groceryListBloc = GroceryListBloc(
      [
        GroceryItem(),
        GroceryItem(),
      ],
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    for (int i = 0; i < groceryListBloc.items.length; i++) {
      items.add(
        Padding(
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<GroceryListBloc, GroceryListState>(
            buildWhen: (previous, current) => current is ItemChangedState,
            builder: (context, state) => GroceryListItem(index: i),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => groceryListBloc,
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment(0, 0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: items,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
