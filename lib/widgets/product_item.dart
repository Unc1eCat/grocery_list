import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/controllers/products_list_controller.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/screens/product_edit_screen.dart';
import 'package:grocery_list/widgets/grocery_item_amount.dart';
import 'package:grocery_list/controllers/grocery_list_items_expansion_controller.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:my_utilities/color_utils.dart';

import 'action_button.dart';
import 'beautiful_text_field.dart';
import 'grocery_item_tag_setting.dart';
import 'heavy_touch_button.dart';

class ProductListItem extends StatelessWidget {
  final ProductsListController listController;
  final GroceryPrototype fallbackModel;

  const ProductListItem({
    Key key,
    this.listController,
    this.fallbackModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return AnimatedBuilder(
      animation: listController,
      builder: (context, child) {
        var isExpanded = listController.expandedProductItemId == this.fallbackModel.id;
      
        return AnimatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: isExpanded ? Theme.of(context).primaryColorLight.withOpacity(0.02) : Colors.transparent,
          duration: Duration(milliseconds: 400),
          child: RepaintBoundary(
            child: AnimatedSize(
              duration: Duration(milliseconds: 400),
              alignment: Alignment.topCenter,
              child: BlocBuilder<GroceryListBloc, GroceryListState>(
                buildWhen: (previous, current) => current is PrototypeChangedState && current.updatedPrototype.id == this.fallbackModel.id,
                cubit: bloc,
                builder: (context, state) {
                  var model = bloc.getPrototypeOfId(this.fallbackModel.id) ?? this.fallbackModel;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.transparent,
                        highlightColor: Theme.of(context).colorScheme.onBackground.blendedWith(Theme.of(context).primaryColor, 0.3).withOpacity(0.06),
                        onTap: () => listController.expandedProductItemId = this.fallbackModel.id,
                        child: SizedBox(
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: isExpanded ? 3.2 : 0.0),
                                      child: isExpanded
                                          ? SmartTextField(
                                              controller: TextEditingController(text: model.title),
                                              decoration: InputDecoration(border: InputBorder.none),
                                              focusNode: FocusNode(),
                                              onEditingComplete: (textField) =>
                                                  bloc.updatePrototype(bloc.getPrototypeOfId(this.fallbackModel.id).copyWith(title: textField.controller.text)),
                                              textAlignVertical: TextAlignVertical.center,
                                              style: Theme.of(context).textTheme.caption,
                                              // scrollPadding: EdgeInsets.zero,
                                            )
                                          : Text(
                                              model.title,
                                              style: Theme.of(context).textTheme.caption,
                                            ),
                                    ),
                                  ),
                                  Text(
                                    bloc.countItemsBoundToProduct(model.id).toString() + " items",
                                    style: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).colorScheme.onBackground.blendedWithInversion(0.2)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                        child: isExpanded
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

                                              bloc.updatePrototype(
                                                  model.copyWith(quantization: value, quantizationDecimalNumbersAmount: dot == -1 ? 0 : state.controller.text.length - 1 - dot));
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
                                            onEditingComplete: (state) => bloc.updatePrototype(model.copyWith(unit: state.controller.text)),
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
                                              bloc.updatePrototype(itemOfId.copyWith(price: double.tryParse(state.controller.text) ?? itemOfId.price));
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
                                            onEditingComplete: (state) => bloc.updatePrototype(model.copyWith(currency: state.controller.text)),
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
                                          onPressed: () => bloc.removeProduct(this.fallbackModel.id),
                                          color: Colors.red[600],
                                          icon: Icons.delete_rounded,
                                          title: "Delete",
                                        ),
                                        ActionButton(
                                          onPressed: () => bloc.addPrototype(model.copyWith(id: DateTime.now().toString())),
                                          color: Colors.amber[600],
                                          icon: Icons.copy_rounded,
                                          title: "Duplicate",
                                        ),
                                      ],
                                    ),
                                  ),
                                  HeavyTouchButton(
                                    onPressed: () => listController.expandedProductItemId = null,
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
      },
    );
  }
}
