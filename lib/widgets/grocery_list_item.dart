import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/list_item_edit_screen.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:grocery_list/widgets/tag_widget.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class GroceryListItem extends StatelessWidget {
  final String id;

  const GroceryListItem({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);
    var model = bloc.getItemOfId(id) ?? ((bloc.state is ItemDeletedState) ? (bloc.state as ItemDeletedState).removedItem : null);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).colorScheme.onBackground.blendedWith(Theme.of(context).primaryColor, 0.3).withOpacity(0.06),
        onLongPress: () => Navigator.of(context).push(ListItemEditRoute(bloc: bloc, id: id)),
        child: Row(
          children: [
            Hero(
              tag: "check$id",
              child: HeavyTouchButton(
                onPressed: () => bloc.updateItem(id, model.copyWith(checked: !model.checked)),
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListItemCheckBox(checked: model.checked),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            SizedBox(
              height: 30,
              child: Hero(
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Align(
                    alignment: Alignment(animation.value - 1.0, 0.0),
                    child: Transform.scale(
                      scale: 1.0 + animation.value * 12 / 18,
                      child: Text(
                        model.title,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                  //   SizedBox(
                  //     height: 30,
                  //     child: Align(
                  //       alignment: Alignment(animation.value - 1.0, 0.0),
                  //       child: Text(
                  //         model.title,
                  //         style: Theme.of(context).textTheme.caption.copyWith(fontSize: 18 + 12 * animation.value),
                  //       ),
                  //     ),
                  //   ),
                ),
                tag: "title$id",
                child: Text(
                  model.title,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              height: 30,
              child: TagWidget(
                tags: model.tags,
              ),
            ),
            SizedBox(width: 20),
            Hero(
              tag: "num$id",
              child: Text(
                model.amount.toStringAsFixed(model.quantizationDecimalNumbersAmount) + (model.unit == null ? "" : " " + model.unit),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            SizedBox(width: 20),
            Handle(
              child: Icon(Icons.drag_handle_rounded),
              vibrate: true,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
