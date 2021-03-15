import 'package:flutter/material.dart';
import 'package:grocery_list/screens/list_screen.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';

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
    return Scaffold(
      body: TabsCornerDrawer(
        screens: [
          ListScreen(),
          Align(
            alignment: Alignment.centerRight,
            child: Text("Test screen 2"),
          ),
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
                child: Text("Grocery list", style: Theme.of(context).textTheme.headline6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Builder(
              builder: (context) => HeavyTouchButton(
                pressedScale: 0.9,
                onPressed: () => context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 1,
                child: Text("Test button 2", style: Theme.of(context).textTheme.headline6),
              ),
            ),
          ),
        ],
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
      ),
      // CornerDrawer(
      //   drawerWidth: 240,
      //   closedButton: Icon(Icons.menu_outlined, size: 36),
      //   // overlap: 0.2,
      //   expandedChild: Padding(
      //     padding: const EdgeInsets.only(top: 100.0),
      //     child: Text("Something", style: Theme.of(context).textTheme.headline6),
      //   ),
      //   opennedButton: FittedBox(
      //     fit: BoxFit.scaleDown,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text("Close", style: Theme.of(context).textTheme.headline6),
      //         SizedBox(width: 20),
      //         Icon(Icons.close, size: 36),
      //       ],
      //     ),
      //   ),
      //   screen: ListScreen(),
      // ),
    );
  }
}
