import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:my_utilities/color_utils.dart';

class SearchResultCreateProductless extends StatelessWidget {
  final String name;
  final String listId;

  const SearchResultCreateProductless({Key key, this.name, this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var th = Theme.of(context);
    var fadedTextStyle = th.textTheme.caption.copyWith(color: th.textTheme.caption.color?.blendedWithInversion(0.2) ?? th.colorScheme.onBackground.blendedWithInversion(0.2));

    return HeavyTouchButton(
      onPressed: () {
        GroceryListBloc.of(context).addItem(ProductlessGroceryItem(title: name, amount: 1.0), listId);
        Navigator.of(context).pop();
      },
      child: Material(
        type: MaterialType.button,
        elevation: 0,
        color: th.colorScheme.onBackground.inverted.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: "Create ", style: fadedTextStyle),
              TextSpan(
                text: name,
                style: th.textTheme.caption,
              ),
              TextSpan(text: " without product", style: fadedTextStyle),
            ]),
          ),
        ),
      ),
    );
  }
}

class SearchResultIncreaseExisting extends StatelessWidget {
  final String id;
  final String listId;

  const SearchResultIncreaseExisting({Key key, this.id, this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var th = Theme.of(context);
    var bloc = GroceryListBloc.of(context);
    var model = bloc.getItemOfId(id, listId);

    return HeavyTouchButton(
      onPressed: () {
        bloc.updateItem(id, model.copyWith(amount: model.amount + model.quantization), listId);
      },
      child: Material(
        type: MaterialType.button,
        elevation: 0,
        color: Theme.of(context).colorScheme.onBackground.inverted.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: "Increase ",
                style: th.textTheme.caption.copyWith(color: th.textTheme.caption.color?.blendedWithInversion(0.2) ?? th.colorScheme.onBackground.blendedWithInversion(0.2)),
              ),
              TextSpan(
                text: model.title,
                style: th.textTheme.caption,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class SearchResultWithProduct extends StatelessWidget {
  final String name;
  final String listId;

  const SearchResultWithProduct({Key key, this.name, this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var th = Theme.of(context);
    var bloc = GroceryListBloc.of(context);

    return HeavyTouchButton(
      onPressed: () {
        var p = GroceryPrototype(title: name);
        bloc.addPrototype(p);
        bloc.addItem(ProductfulGroceryItem(boundPrototype: p, amount: p.quantization), listId);
      },
      child: Material(
        type: MaterialType.button,
        elevation: 0,
        color: th.colorScheme.onBackground.inverted.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: "Create from new product ",
                style: th.textTheme.caption.copyWith(color: th.textTheme.caption.color?.blendedWithInversion(0.2) ?? th.colorScheme.onBackground.blendedWithInversion(0.2)),
              ),
              TextSpan(
                text: name,
                style: th.textTheme.caption,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class SearchResultFromProduct extends StatelessWidget {
  final String productId;
  final String listId;

  const SearchResultFromProduct({Key key, this.productId, this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var th = Theme.of(context);
    var bloc = GroceryListBloc.of(context);
    var prod = bloc.getPrototypeOfId(productId);

    return HeavyTouchButton(
      onPressed: () {
        bloc.addItem(ProductfulGroceryItem(boundPrototype: prod, amount: prod.quantization), listId);
      },
      child: Material(
        type: MaterialType.button,
        elevation: 0,
        color: th.colorScheme.onBackground.inverted.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            prod.title,
            style: th.textTheme.caption,
          ),
        ),
      ),
    );
  }
}
