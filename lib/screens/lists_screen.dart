import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/lists_view_item.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = GroceryListBloc.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          BlocBuilder<GroceryListBloc, GroceryListState>(
            cubit: bloc,
            buildWhen: (prev, cur) => cur is ListsListModifiedState,
            builder: (context, state) {
              print(state);
              return ImplicitlyAnimatedReorderableList<String>(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.0, left: 10.0, right: 10.0),
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                items: bloc.lists.map((e) => e.id).toList(),
                itemBuilder: (context, anim, id, i) => Reorderable(
                  key: ValueKey(id),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Handle(
                      delay: Duration(milliseconds: 300),
                      child: ListsViewItem(
                        id: id,
                        bloc: bloc,
                      ),
                    ),
                  ),
                ),
                areItemsTheSame: (a, b) => a == b,
                onReorderFinished: (id, from, to, newItems) => bloc.moveList(from, to),
              );
            }
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: HeavyTouchButton(
              onPressed: () => bloc.addList(GroceryList(title: "New List")),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(Icons.add_rounded, size: 40,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
