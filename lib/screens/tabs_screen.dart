import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/screens/list_screen.dart';
import 'package:grocery_list/screens/products_screen.dart';
import 'package:grocery_list/screens/settings_screen.dart';
import 'package:grocery_list/widgets/colored_tab.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import '../utils/golden_ration_utils.dart' as gr;
import 'package:my_utilities/color_utils.dart';

import 'lists_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);

    return Material(
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<GroceryListBloc, GroceryListState>(
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

                return TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _controller,
                  children: [
                    ListsScreen(),
                    SettingsScreen(),
                  ],
                );
              },
            ),
          ),
          ColoredBox(
            color: Colors.black,
            child: TabBar(
              controller: _controller,
              indicatorColor: Colors.transparent,
              tabs: [
                ColoredTab(
                  controller: _controller,
                  index: 0,
                  icon: Icon(
                    Icons.format_list_bulleted_rounded,
                  ),
                  // text: "Lists",
                  selectedColor: Colors.green[600],
                  unselectedColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.65),
                ),
                ColoredTab(
                  controller: _controller,
                  index: 1,
                  icon: Icon(
                    Icons.person_rounded,
                  ),
                  // text: "Profile",
                  selectedColor: Colors.blueAccent,
                  unselectedColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.65),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
