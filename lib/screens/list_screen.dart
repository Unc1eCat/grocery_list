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
import 'package:rive/rive.dart';

import '../bloc/grocery_list_bloc.dart';
import '../bloc/grocery_list_bloc.dart';

class ListScreen extends StatelessWidget {
  final String listId;

  const ListScreen({Key key, this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var groceryListBloc = BlocProvider.of<GroceryListBloc>(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: BlocBuilder<GroceryListBloc, GroceryListState>(
              buildWhen: (prev, state) {
                return ((state is ItemDeletedState || state is ItemCreatedState) && (state as WithinListState).listId == listId) ||
                    state is ItemsFetchedState;
              },
              cubit: groceryListBloc,
              builder: (context, state) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: ImplicitlyAnimatedReorderableList<GroceryItem>(
                  onReorderFinished: (item, from, to, newItems) => groceryListBloc.moveItem(from, to, listId),
                  areItemsTheSame: (a, b) => a.id == b.id,
                  itemBuilder: (context, animation, item, i) {
                    return Reorderable(
                      key: ValueKey(item.id),
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: BlocBuilder<GroceryListBloc, GroceryListState>(
                            buildWhen: (previous, current) => current is ItemsChangedState && current.contains(item.id),
                            cubit: groceryListBloc,
                            builder: (context, state) => GroceryListItem(
                              id: item.id,
                              key: ValueKey(item.id),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  items: groceryListBloc.getListOfId(listId).items,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 86,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
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
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                HeavyTouchButton(
                  onPressed: () {},
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).cardColor.blendedWithInversion(0.05), width: 1.1),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Theme.of(context).shadowColor.withOpacity(0.0),
                          spreadRadius: 2,
                        ),
                      ],
                      color: Theme.of(context).cardColor,
                    ),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.edit_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
