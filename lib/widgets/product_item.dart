import 'package:flutter/material.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/screens/product_edit_screen.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class ProductListItem extends StatelessWidget {
  final GroceryPrototype model;

  const ProductListItem({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var propsStyle = Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.72));

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).colorScheme.onBackground.blendedWith(Theme.of(context).primaryColor, 0.3).withOpacity(0.06),
        onLongPress: () => Navigator.of(context).push(ProductItemEditRoute(id: model.id)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                ),
                tag: "title${model.id}",
                child: Align(
                  // alignment: Alignment.centerLeft,
                  child: Text(
                    model.title,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ),
            Spacer(),
            Hero(
              tag: "quantization${model.id}",
              child: Text(
                model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount) + " ",
                style: propsStyle,
              ),
            ),
            Hero(
              tag: "unit${model.id}",
              child: Text(
                model.unit + "   ",
                style: propsStyle,
              ),
            ),
            Hero(
              tag: "price${model.id}",
              child: Text(
                model.price.toStringAsFixed(2) + " ",
                style: propsStyle,
              ),
            ),
            Hero(
              tag: "currency${model.id}",
              child: Text(
                model.currency,
                style: propsStyle,
              ),
            ),
            SizedBox(width: 22),
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
