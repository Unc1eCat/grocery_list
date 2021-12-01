import 'dart:math';

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
import 'package:grocery_list/widgets/grocery_item_amount.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:grocery_list/widgets/tag_widget.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

class GroceryListItem extends StatelessWidget {
  final GroceryItem fallbackModel;
  final String listId;
  final GroceryItemExpansionController expansionController;

  const GroceryListItem({Key key, this.fallbackModel, this.listId, this.expansionController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return AnimatedBuilder(
      animation: expansionController,
      builder: (context, child) {
        var expanded = expansionController.expandedGroceryItemId == fallbackModel.id;
        var th = Theme.of(context);

        return AnimatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: expanded ? th.primaryColorLight.withOpacity(0.02) : Colors.transparent,
          duration: Duration(milliseconds: 400),
          child: RepaintBoundary(
            child: AnimatedSize(
              duration: Duration(milliseconds: 400),
              alignment: Alignment.topCenter,
              child: BlocBuilder<GroceryListBloc, GroceryListState>(
                buildWhen: (previous, current) => current is ItemsChangedState && current.contains(this.fallbackModel.id),
                cubit: bloc,
                builder: (context, state) {
                  var model = bloc.getItemOfId(this.fallbackModel.id, listId) ?? this.fallbackModel;
                  var productBound = model is ProductfulGroceryItem;

                  Widget detailsPanel;

                  if (expanded) {
                    if (productBound) {
                      var subDetailsProductful = expansionController.isProductEditingExpanded
                          ? Column(
                              key: ValueKey(true),
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
                                        flex: 2,
                                        child: BeautifulTextField(
                                          label: "Quantization",
                                          controller: TextEditingController(text: model.quantization.toStringAsFixed(model.quantizationFractionDigits)),
                                          focusNode: FocusNode(),
                                          onEditingComplete: (state) {
                                            var value = double.tryParse(state.controller.text);
                                            var oldModel = bloc.getPrototypeOfId(model.id);

                                            if (value == null || value < 0) {
                                              state.controller.text = oldModel.quantization.toStringAsFixed(model.quantizationFractionDigits);
                                              return;
                                            }

                                            var dot = state.controller.text.lastIndexOf(RegExp(",|\\."));

                                            bloc.updatePrototype(model.boundPrototype
                                                .copyWith(quantization: value, quantizationDecimalNumbersAmount: dot == -1 ? 0 : state.controller.text.length - 1 - dot));
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        flex: 1,
                                        child: BeautifulTextField(
                                          label: "Unit",
                                          controller: TextEditingController(text: model.unit),
                                          focusNode: FocusNode(),
                                          onEditingComplete: (state) => bloc.updatePrototype(model.boundPrototype.copyWith(unit: state.controller.text)),
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
                                        flex: 2,
                                        child: BeautifulTextField(
                                          label: "Price",
                                          controller: TextEditingController(text: model.price.toStringAsFixed(2)),
                                          focusNode: FocusNode(),
                                          onEditingComplete: (state) {
                                            bloc.updatePrototype(model.boundPrototype.copyWith(price: double.tryParse(state.controller.text) ?? model.boundPrototype.price));
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        flex: 1,
                                        child: BeautifulTextField(
                                          label: "Currency",
                                          controller: TextEditingController(text: model.currency),
                                          focusNode: FocusNode(),
                                          onEditingComplete: (state) => bloc.updatePrototype(model.boundPrototype.copyWith(currency: state.controller.text)),
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
                                  child: ActionButton(
                                    onPressed: () => bloc.removeProduct(this.fallbackModel.id),
                                    color: Colors.red[600],
                                    icon: Icons.delete_rounded,
                                    title: "Delete",
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              key: ValueKey(false),
                              children: [
                                HeavyTouchButton(
                                  onPressed: () {},
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color.fromRGBO(30, 30, 30, 0.6),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: model.title + "   ", style: th.textTheme.headline6),
                                            TextSpan(text: "${model.quantization.toStringAsFixed(model.quantizationFractionDigits)} ${model.unit}", style: th.textTheme.headline6),
                                            TextSpan(text: " for ", style: th.textTheme.caption.copyWith(color: th.colorScheme.onBackground.blendedWithInversion(0.2))),
                                            TextSpan(text: "${model.price} ${model.currency}", style: th.textTheme.headline6),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
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
                                        onPressed: () => bloc.removeItem(this.fallbackModel.id, listId),
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
                              ],
                            );

                      detailsPanel = Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: SizedBox(
                              height: 24,
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 400),
                                    child: expansionController.isProductEditingExpanded
                                        ? HeavyTouchButton(
                                            onPressed: () => expansionController.isProductEditingExpanded = false,
                                            child: Icon(Icons.arrow_back_rounded),
                                          )
                                        : SizedBox(width: 24),
                                  ),
                                  Text(
                                    "Bound to product:",
                                    textAlign: TextAlign.center,
                                    style: th.textTheme.caption.copyWith(color: th.colorScheme.onBackground.blendedWithInversion(0.2)),
                                  ),
                                  SizedBox(width: 24),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: subDetailsProductful,
                          ),
                          HeavyTouchButton(
                            onPressed: () => expansionController.expandedGroceryItemId = null,
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Icon(Icons.expand_less_rounded),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      detailsPanel = Column(
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
                                  flex: 2,
                                  child: BeautifulTextField(
                                    label: "Quantization",
                                    controller: TextEditingController(text: model.quantization.toStringAsFixed(model.quantizationFractionDigits)),
                                    focusNode: FocusNode(),
                                    onEditingComplete: (state) {
                                      var value = double.tryParse(state.controller.text);
                                      var oldModel = bloc.getItemOfId(this.fallbackModel.id, listId);

                                      if (value == null || value < 0) {
                                        state.controller.text = oldModel.quantization.toStringAsFixed(model.quantizationFractionDigits);
                                        return;
                                      }

                                      var dot = state.controller.text.lastIndexOf(RegExp(",|\\."));

                                      bloc.updateItem(
                                        this.fallbackModel.id,
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
                                  flex: 1,
                                  child: BeautifulTextField(
                                    label: "Unit",
                                    controller: TextEditingController(text: model.unit),
                                    focusNode: FocusNode(),
                                    onEditingComplete: (state) => bloc.updateItem(this.fallbackModel.id, model.copyWith(unit: state.controller.text), listId),
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
                                  flex: 2,
                                  child: BeautifulTextField(
                                    label: "Price",
                                    controller: TextEditingController(text: model.price.toStringAsFixed(2)),
                                    focusNode: FocusNode(),
                                    onEditingComplete: (state) {
                                      var itemOfId = model;
                                      bloc.updateItem(this.fallbackModel.id, itemOfId.copyWith(price: double.tryParse(state.controller.text) ?? itemOfId.price), listId);
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: BeautifulTextField(
                                    label: "Currency",
                                    controller: TextEditingController(text: model.currency),
                                    focusNode: FocusNode(),
                                    onEditingComplete: (state) => bloc.updateItem(this.fallbackModel.id, model.copyWith(currency: state.controller.text), listId),
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
                                  style: th.textTheme.caption,
                                  ticked: true,
                                  title: "For Cat",
                                ),
                                GroceryItemTagSetting(
                                  color: Colors.purple,
                                  style: th.textTheme.caption,
                                  title: "Expansive",
                                ),
                                GroceryItemTagSetting(
                                  color: Colors.green,
                                  style: th.textTheme.caption,
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
                                  onPressed: () => bloc.removeItem(this.fallbackModel.id, listId),
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
                            onPressed: () => expansionController.expandedGroceryItemId = null,
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Icon(Icons.expand_less_rounded),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    detailsPanel = SizedBox.shrink();
                  }

                  var topRow = InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: Colors.transparent,
                    highlightColor: th.colorScheme.onBackground.blendedWith(th.primaryColor, 0.3).withOpacity(0.06),
                    onTap: expanded ? null : () => expansionController.expandedGroceryItemId = this.fallbackModel.id,
                    child: Row(
                      // Title, checkbox and amount
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HeavyTouchButton(
                          onPressed: () => bloc.updateItem(this.fallbackModel.id, model = model.copyWith(checked: !model.checked), listId),
                          child: ColoredBox(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListItemCheckBox(checked: model.checked),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        if (expanded && !productBound)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SmartTextField(
                                controller: TextEditingController(text: model.title),
                                decoration: InputDecoration(border: InputBorder.none),
                                focusNode: FocusNode(),
                                onEditingComplete: (textField) =>
                                    bloc.updateItem(this.fallbackModel.id, bloc.getItemOfId(this.fallbackModel.id, listId).copyWith(title: textField.controller.text), listId),
                                textAlignVertical: TextAlignVertical.center,
                                style: th.textTheme.caption,
                                // scrollPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        if (!(expanded && !productBound))
                          Text(
                            model.title,
                            style: th.textTheme.caption,
                          ),
                        Spacer(),
                        SizedBox(width: 20),
                        GroceryItemAmount(
                          expanded: expansionController.expandedGroceryItemId == model.id,
                          fractionDigits: model.quantizationFractionDigits,
                          quantize: model.quantization,
                          unit: model.unit,
                          value: model.amount,
                          onChanged: (value) => bloc.updateItem(model.id, model.copyWith(amount: value), listId),
                        ),
                      ],
                    ),
                  );

                  return Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: topRow,
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(begin: Offset(0, -0.2), end: Offset(0, 0)).animate(animation),
                            child: child,
                          ),
                        ),
                        child: detailsPanel,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
