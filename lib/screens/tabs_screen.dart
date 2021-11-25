import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/screens/list_screen.dart';
import 'package:grocery_list/screens/products_screen.dart';
import 'package:grocery_list/screens/settings_screen.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import '../utils/golden_ration_utils.dart' as gr;

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 1, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);

    return Scaffold(
      body: BlocBuilder<GroceryListBloc, GroceryListState>(
          cubit: bloc,
          buildWhen: (_, current) => current is ListsListModifiedState,
          builder: (context, state) {
            var listButtons = <Widget>[];

            for (var i = 0; i < bloc.lists.length; i++) {
              listButtons.add(
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Builder(
                    builder: (context) => HeavyTouchButton(
                      pressedScale: 0.9,
                      onPressed: () => context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 2 + i,
                      child: Text(bloc.lists[i].title, style: Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ),
              );
            }

            return TabsCornerDrawer(
              screens: [
                SettingsScreen(),
                ProductsScreen(),
                ...bloc.lists.map((e) => ListScreen(listId: e.id)).toList(),
              ],
              pointer: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.circle,
                  size: 6,
                ),
              ),
              tabButtons: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Builder(
                    builder: (context) => HeavyTouchButton(
                      pressedScale: 0.9,
                      onPressed: () => context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 0,
                      child: Text("Settings", style: Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Builder(
                    builder: (context) => HeavyTouchButton(
                      pressedScale: 0.9,
                      onPressed: () => context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 1,
                      child: Text("Products", style: Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ),
                ...listButtons,
              ],
              screenChangeDuration: Duration(milliseconds: 400),
              extendedChildTransitionBuilder: (context, animation, child) => Column(
                children: [
                  Spacer(flex: 1000),
                  child,
                  Spacer(flex: (gr.invphi * gr.invphi * 1000).toInt()),
                  HeavyTouchButton(
                    onPressed: () => bloc.addList(GroceryList(title: "New list")),
                    child: FadeTransition(
                      opacity: animation,
                      child: Text("+ Create list", style: Theme.of(context).textTheme.button),
                    ),
                  ),
                  Spacer(flex: (gr.invphi * 1000).toInt()),
                ],
              ),
              closedButton: (context, onPressed, _, __) => HeavyTouchButton(
                onPressed: onPressed,
                pressedScale: 0.9,
                child: Icon(Icons.menu_rounded, size: 32),
              ),
              openedButton: (context, onPressed, _, __) => HeavyTouchButton(
                onPressed: onPressed,
                pressedScale: 0.9,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Close", style: Theme.of(context).textTheme.headline6),
                      SizedBox(width: 20),
                      Icon(Icons.close_rounded, size: 32),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
