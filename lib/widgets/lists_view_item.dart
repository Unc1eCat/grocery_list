import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/screens/list_screen.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';

class ListsViewItem extends StatelessWidget {
  final GroceryListBloc bloc;
  final String id;

  const ListsViewItem({Key key, this.bloc, @required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var model = bloc.getListOfId(id);

    return HeavyTouchButton(
      onPressed: () => Navigator.of(context).push(
        ListScreen(
          listId: id,
        ),
      ),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                model.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Spacer(),
              Text(
                model.items.length.toString(),
                style: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
