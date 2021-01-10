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
          Center(
            child: Text("Test screen 1"),
          ),
          Center(
            child: Text("Test screen 2"),
          ),
        ],
        pointer: Icon(Icons.circle),
        tabButtons: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: HeavyTouchButton(
              onPressed: () => context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 0,
              child: Text("Test button 0"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Builder(
              builder: (context) => RaisedButton(
                onPressed: () {
                  print("hadfsfg");
                  context.findAncestorStateOfType<TabsCornerDrawerState>().currentIndex = 1;
                },
                child: Text("Test button 1"),
              ),
            ),
          ),
        ],
        closedButton: Icon(Icons.menu_outlined, size: 36),
        opennedButton: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Close", style: Theme.of(context).textTheme.headline6),
              SizedBox(width: 20),
              Icon(Icons.close, size: 36),
            ],
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
