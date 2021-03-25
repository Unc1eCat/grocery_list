import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/add_item_screen.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:my_utilities/color_utils.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    var groceryListBloc = BlocProvider.of<GroceryListBloc>(context);
    GlobalKey<AnimatedListState> animatedList = GlobalKey<AnimatedListState>();

    return BlocProvider(
      create: (context) => groceryListBloc,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocBuilder<GroceryListBloc, GroceryListState>(
                  buildWhen: (prev, state) {
                    return state is ItemDeletedState || state is ItemCreatedState || state is ItemsFetchedState;
                  },
                  cubit: groceryListBloc,
                  builder: (context, state) => ImplicitlyAnimatedReorderableList(
                    onReorderFinished: (item, from, to, newItems) => groceryListBloc.moveItem(from, to),
                    areItemsTheSame: (a, b) => a.id == b.id,
                    footer: BlocBuilder<GroceryListBloc, GroceryListState>(
                      buildWhen: (previous, current) => current is CheckedChangedState,
                      cubit: groceryListBloc,
                      builder: (context, state) => AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: RotationTransition(
                            alignment: Alignment(-1.2, -0.8),
                            turns: Tween<double>(begin: 0.05, end: 0.0).animate(animation),
                            // position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(animation),
                            child: child,
                          ),
                        ),
                        child: groceryListBloc.items.any((e) => e.checked)
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: HeavyTouchButton(
                                  pressedScale: 0.9,
                                  onPressed: () {},
                                  child: Material(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xFF0E1C21),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_box_rounded,
                                            // color: Colors.white70,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Remove checked items",
                                            style: Theme.of(context).textTheme.button,
                                            // .copyWith(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                    itemBuilder: (context, animation, item, i) {
                      var e = groceryListBloc.items[i];

                      return Reorderable(
                        key: ValueKey(e.id),
                        child: ScaleTransition(
                          scale: animation,
                          child: BlocBuilder<GroceryListBloc, GroceryListState>(
                            buildWhen: (previous, current) => current is ItemChangedState && current.id == e.id,
                            cubit: groceryListBloc,
                            builder: (context, state) => GroceryListItem(
                              id: e.id,
                              key: ValueKey(e.id),
                            ),
                          ),
                        ),
                      );
                    },
                    key: animatedList,
                    items: groceryListBloc.items,
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    // children: groceryListBloc.items.values.map((e) => GroceryListItem(id: e.id, key: ValueKey(e.id))).toList(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 24,
              right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 14),
                  Hero(
                    tag: "addItem",
                    child: HeavyTouchButton(
                      onPressed: () {
                        if (ModalRoute.of(context).isCurrent) {
                          print("Tap");
                          Navigator.push(context, AddItemScreen());
                        }
                      },
                      pressedScale: 0.9,
                      child: Material(
                        color: const Color.fromARGB(255, 250, 250, 250),
                        elevation: 6,
                        borderRadius: BorderRadius.circular(8),
                        type: MaterialType.button,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            "+  Create item",
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
