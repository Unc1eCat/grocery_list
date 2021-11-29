import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/list_item_edit_screen.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/beautiful_text_field.dart';
import 'package:grocery_list/widgets/grocery_item_tag_setting.dart';
import 'package:grocery_list/widgets/grocery_list_items_expansion_controller.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:grocery_list/widgets/tag_widget.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class GroceryListItem extends StatelessWidget {
  final String id;
  final String listId;
  final GroceryListItemsExpansionController expansionController;

  const GroceryListItem({Key key, this.id, this.listId, this.expansionController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return AnimatedBuilder(
      animation: expansionController,
      builder: (context, child) => AnimatedContainer(
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: expansionController.expandedGroceryListItemDetails == id ? Theme.of(context).colorScheme.onBackground.withOpacity(0.02) : Colors.transparent,
        duration: Duration(milliseconds: 300),
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: BlocBuilder<GroceryListBloc, GroceryListState>(
            buildWhen: (previous, current) => current is ItemsChangedState && current.contains(id),
            cubit: bloc,
            builder: (context, state) {
              var model = bloc.getItemOfId(id, listId);

              return Column(
                children: [
                  expansionController.expandedGroceryListItemDetails == id
                      ? SizedBox(
                          height: 50,
                          child: Row(
                            // Title, checkbox and amount
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HeavyTouchButton(
                                onPressed: () => bloc.updateItem(id, model = model.copyWith(checked: !model.checked), listId),
                                child: ColoredBox(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ListItemCheckBox(checked: model.checked),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: SmartTextField(
                                    controller: TextEditingController(text: model.title),
                                    decoration: InputDecoration(border: InputBorder.none),
                                    focusNode: FocusNode(),
                                    onEditingComplete: (textField) => bloc.updateItem(id, bloc.getItemOfId(id, listId).copyWith(title: textField.controller.text), listId),
                                    textAlignVertical: TextAlignVertical.center,
                                    style: Theme.of(context).textTheme.caption,
                                    // scrollPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                // TODO: Editable number
                                model.amount.toStringAsFixed(model.quantizationDecimalNumbersAmount) + (model.unit == null ? "" : " " + model.unit),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.transparent,
                          highlightColor: Theme.of(context).colorScheme.onBackground.blendedWith(Theme.of(context).primaryColor, 0.3).withOpacity(0.06),
                          onTap: () => expansionController.expandedGroceryListItemDetails = id,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              // Collapsed
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                HeavyTouchButton(
                                  onPressed: () => bloc.updateItem(id, model = model.copyWith(checked: !model.checked), listId),
                                  child: ColoredBox(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ListItemCheckBox(checked: model.checked),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  model.title,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Spacer(),
                                SizedBox(width: 20),
                                Text(
                                  model.amount.toStringAsFixed(model.quantizationDecimalNumbersAmount) + (model.unit == null ? "" : " " + model.unit),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: Offset(0, -0.2), end: Offset(0, 0)).animate(animation),
                        child: child,
                      ),
                    ),
                    child: expansionController.expandedGroceryListItemDetails == id
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                                child: Row(
                                  // First text fields row
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: BeautifulTextField(
                                        label: "Quantization",
                                        controller: TextEditingController(text: model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount)),
                                        focusNode: FocusNode(),
                                        onEditingComplete: (state) {
                                          var value = double.tryParse(state.controller.text);
                                          var oldModel = bloc.getItemOfId(id, listId);

                                          if (value == null || value < 0) {
                                            state.controller.text = oldModel.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount);
                                            return;
                                          }

                                          var dot = state.controller.text.lastIndexOf(RegExp(",|\\."));

                                          bloc.updateItem(
                                            id,
                                            model.copyWith(
                                                quantization: value,
                                                quantizationDecimalNumbersAmount: dot == -1 ? 0 : state.controller.text.length - 1 - dot,
                                                amount: (model.amount / value).round() * value),
                                            listId,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: BeautifulTextField(
                                        label: "Unit",
                                        controller: TextEditingController(text: model.unit),
                                        focusNode: FocusNode(),
                                        onEditingComplete: (state) => bloc.updateItem(id, model.copyWith(unit: state.controller.text), listId),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                                child: Row(
                                  // Second text fields row
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: BeautifulTextField(
                                        label: "Price",
                                        controller: TextEditingController(text: model.price.toStringAsFixed(2)),
                                        focusNode: FocusNode(),
                                        onEditingComplete: (state) {
                                          var itemOfId = model;
                                          bloc.updateItem(id, itemOfId.copyWith(price: double.tryParse(state.controller.text) ?? itemOfId.price), listId);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: BeautifulTextField(
                                        label: "Currency",
                                        controller: TextEditingController(text: model.currency),
                                        focusNode: FocusNode(),
                                        onEditingComplete: (state) => bloc.updateItem(id, model.copyWith(currency: state.controller.text), listId),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                                child: Wrap(
                                  runSpacing: 12,
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 10,
                                  children: [
                                    GroceryItemTagSetting(
                                      color: Colors.deepOrange,
                                      style: Theme.of(context).textTheme.caption,
                                      ticked: true,
                                      title: "For Cat",
                                    ),
                                    GroceryItemTagSetting(
                                      color: Colors.purple,
                                      style: Theme.of(context).textTheme.caption,
                                      title: "Expansive",
                                    ),
                                    GroceryItemTagSetting(
                                      color: Colors.green,
                                      style: Theme.of(context).textTheme.caption,
                                      title: "For Fun",
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                                child: Wrap(
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  children: [
                                    ActionButton(
                                      onPressed: () => bloc.removeItem(id, listId),
                                      color: Colors.red[600],
                                      icon: Icons.delete_rounded,
                                      title: "Delete",
                                    ),
                                    ActionButton(
                                      onPressed: () => bloc.addItem(model.copyWith(id: DateTime.now().toString()), listId),
                                      color: Colors.amber[600],
                                      icon: Icons.copy_rounded,
                                      title: "Duplicate",
                                    ),
                                  ],
                                ),
                              ),
                              HeavyTouchButton(
                                onPressed: () => expansionController.expandedGroceryListItemDetails = null,
                                child: ColoredBox(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: Icon(Icons.expand_less_rounded),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
