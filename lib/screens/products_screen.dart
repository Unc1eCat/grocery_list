import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/screens/product_edit_screen.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/product_item.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: BlocBuilder<GroceryListBloc, GroceryListState>(
                cubit: bloc,
                buildWhen: (previous, current) => current is PrototypeAddedState || current is PrototypeRemovedState || current is PrototypesFetchedState,
                builder: (context, snapshot) {
                  return ImplicitlyAnimatedReorderableList<GroceryPrototype>(
                    onReorderFinished: (item, from, to, newItems) {}, // <---- TODO
                    areItemsTheSame: (a, b) => a.id == b.id,
                    itemBuilder: (context, animation, item, i) {
                      return Reorderable(
                        key: ValueKey(item.id),
                        child: ScaleTransition(
                          scale: animation,
                          child: BlocBuilder<GroceryListBloc, GroceryListState>(
                            buildWhen: (previous, current) {
                              return current is PrototypeChangedState && current.updatedPrototypes.title == item.title;
                            },
                            cubit: bloc,
                            builder: (context, state) {
                              return ProductListItem(
                                model: bloc.prototypes.firstWhere((e) => item.id == e.id, orElse: () => null) ?? item,
                                key: ValueKey(item.title),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    items: bloc.prototypes,
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  );
                }
              ),
            ),
            Positioned(
              bottom: 24,
              right: 90,
              left: 14,
              child: ActionButton(
                onPressed: () 
                {
                  var newProt = GroceryPrototype(title: "New product");
                  bloc.addPrototype(newProt);
                  Navigator.of(context).push(ProductItemEditRoute(id: newProt.id));
                },
                color: Color(0xFF4D5DD5),
                icon: Icons.add_rounded,
                title: "Add product",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
