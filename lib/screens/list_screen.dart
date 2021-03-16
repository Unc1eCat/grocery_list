import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/add_item_screen.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_utilities/color_utils.dart';

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
                child: BlocListener<GroceryListBloc, GroceryListState>(
                  listener: (context, state) {
                    if (state is ItemDeletedState) {
                      animatedList.currentState.removeItem(
                        state.index,
                        (context, animation) => ScaleTransition(
                          scale: animation,
                          child: GroceryListItem(id: state.removedItem.id),
                        ),
                      );
                    } else if (state is ItemCreatedState) {
                      animatedList.currentState.insertItem(groceryListBloc.items.values.toList().indexWhere((e) => e.id == state.id));
                    } else if (state is ItemsFetchedState) {
                      setState(() {});
                    }
                  },
                  cubit: groceryListBloc,
                  child: AnimatedList(
                    key: animatedList,
                    initialItemCount: groceryListBloc.items.length,
                    itemBuilder: (context, index, animation) {
                      var id = groceryListBloc.items.values.elementAt(index).id;
                      return ScaleTransition(
                        scale: animation,
                        child: BlocBuilder<GroceryListBloc, GroceryListState>(
                          buildWhen: (previous, current) => current is ItemChangedState && current.id == id,
                          cubit: groceryListBloc,
                          builder: (context, state) => GroceryListItem(
                            id: id,
                            key: ValueKey(id),
                          ),
                        ),
                      );
                    },
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
              child: Hero(
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
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
