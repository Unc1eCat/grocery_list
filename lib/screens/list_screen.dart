import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
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
  Widget _buildActionButton({
    @required VoidCallback onPressed,
    @required Color color,
    @required IconData icon,
    @required String title,
    @required BuildContext context,
  }) {
    return HeavyTouchButton(
      pressedScale: 0.9,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1.2,
            color: color.withRangedHsvSaturation(0.8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 8,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.button,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var groceryListBloc = BlocProvider.of<GroceryListBloc>(context);

    return BlocProvider(
      create: (context) => groceryListBloc,
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<GroceryListBloc, GroceryListState>(
                buildWhen: (previous, current) =>
                    current is ItemsFetchedState || current is ItemCreatedState || current is ItemDeletedState,
                cubit: groceryListBloc,
                builder: (context, state) {
                  List<Widget> items = [];
                  print('fsdgs');

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

                  return ListView(
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    children: items,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 24,
              right: 100,
              child: _buildActionButton(
                onPressed: () => groceryListBloc.createItem(0, GroceryItem()),
                color: Color(0xff56d17b),
                icon: Icons.add,
                title: "Create new item",
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
