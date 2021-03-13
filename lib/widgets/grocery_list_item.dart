import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/list_item_edit_screen.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:grocery_list/widgets/tag_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;
import 'package:my_utilities/color_utils.dart';

class GroceryListItem extends StatelessWidget {
  final int index;

  const GroceryListItem({Key key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);
    var model = bloc.items[index];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).colorScheme.onBackground.blendedWith(Theme.of(context).primaryColor, 0.3).withOpacity(0.06),
        onLongPress: () => Navigator.of(context).push(ListItemEditRoute(bloc: bloc, index: index)),
        child: Row(
          children: [
            Hero(
              tag: "check$index",
              child: HeavyTouchButton(
                onPressed: () => bloc.updateItem(index, model.copyWith(checked: !model.checked)),
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
            Hero(
              flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Align(
                  alignment: Alignment.topCenter,
                  child: Transform.scale(
                    scale: 1.0 + animation.value * 12 / 18,
                    child: Text(
                      model.title,
                      style: Theme.of(context).textTheme.caption.copyWith(),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 30,
                //   child: Align(
                //     alignment: Alignment.topCenter,
                //     child: Text(
                //       model.title,
                //       style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16 + 12 * animation.value),
                //     ),
                //   ),
                // ),
              ),
              tag: "title$index",
              child: Text(
                model.title,
                style: Theme.of(context).textTheme.caption,
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
              tag: "num$index",
              child: NumberInput(
                fractionDigits: model.integerQuantization ? 0 : 3,
                quantize: 0.6,
                value: model.amount,
                unit: model.unit,
                onChanged: (value) => BlocProvider.of<GroceryListBloc>(context).updateItem(index, model.copyWith(amount: value)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
