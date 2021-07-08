import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/screens/product_edit_screen.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/list_item_property.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:my_utilities/color_utils.dart';
import 'package:path/path.dart';
import '../utils/golden_ration_utils.dart' as gr;

class ListItemEditRoute extends PageRoute with TickerProviderMixin {
  final GroceryListBloc bloc;
  final String id;
  final String listId;

  ListItemEditRoute({this.listId, this.bloc, this.id});

  ScrollController _scrollController;
  AnimationController _animationController;
  GlobalKey<FullSmartTextFieldState> titleKey = GlobalKey<FullSmartTextFieldState>();
  GlobalKey<FullSmartTextFieldState> quantizationKey = GlobalKey<FullSmartTextFieldState>();
  GlobalKey<FullSmartTextFieldState> unitKey = GlobalKey<FullSmartTextFieldState>();
  GlobalKey<FullSmartTextFieldState> priceKey = GlobalKey<FullSmartTextFieldState>();
  GlobalKey<FullSmartTextFieldState> currencyKey = GlobalKey<FullSmartTextFieldState>();

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 600);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => "";

  void _handleScroll() {
    if (_scrollController.offset < -70) {
      _scrollController.removeListener(_handleScroll);
      navigator.pop();
    } else if (_scrollController.offset < 0) {
      _animationController.value = (60 + _scrollController.offset) / 60;
    }
  }

  @override
  void install() {
    _animationController = AnimationController(vsync: this)..animateTo(1.0, duration: const Duration(milliseconds: 600));
    _scrollController = ScrollController()..addListener(_handleScroll);
    popped.then((_) => _animationController.animateBack(0.0, duration: const Duration(milliseconds: 600)));
    super.install();
  }

  @override
  void dispose() {
    disposeTickers();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var model = bloc.getItemOfId(id, listId);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _animationController.value * 2,
              sigmaY: _animationController.value * 2,
            ),
            child: ColoredBox(
              color: Colors.black.withOpacity(_animationController.value * 0.5),
              child: child,
            ),
          ),
          child: SizedBox.expand(),
        ),
        BlocProvider<GroceryListBloc>(
          create: (context) => bloc,
          child: SafeArea(
            child: BlocListener<GroceryListBloc, GroceryListState>(
              cubit: bloc,
              listener: (context, state) {
                if (state is ItemsChangedState && state.contains(id)) {
                  model = bloc.getItemOfId(id, listId);
                  titleKey.currentState.controller.text = model.title;
                  quantizationKey.currentState.controller.text = model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount);
                  unitKey.currentState.controller.text = model.unit;
                  priceKey.currentState.controller.text = model.price.toStringAsFixed(2);
                  currencyKey.currentState.controller.text = model.currency;
                }
              },
              child: ListView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (1 - gr.invphi),
                  ),
                  BlocBuilder<GroceryListBloc, GroceryListState>(
                    cubit: bloc,
                    buildWhen: (previous, current) =>
                        (current is ItemsChangedState && current.reboundPrototype == true && current.contains(id)) ||
                        (current is PrototypeRemovedState && current.prototype.id == bloc.getItemOfId(id, listId).boundPrototype.id),
                    builder: (context, state) => bloc.getItemOfId(id, listId).boundPrototype == null
                        ? SizedBox(
                            width: 300,
                            height: 30,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Hero(
                                tag: "title$id",
                                child: Material(
                                  color: Colors.transparent,
                                  child: SmartTextField(
                                    textCapitalization: TextCapitalization.sentences,
                                    textAlign: TextAlign.center,
                                    scrollPadding: EdgeInsets.zero,
                                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(6), hintText: "Item title"),
                                    cursorWidth: 2,
                                    cursorRadius: Radius.circular(2),
                                    key: titleKey,
                                    onEditingComplete: () => bloc.updateItem(id, model.copyWith(title: titleKey.currentState.controller.text), listId),
                                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                                    style: Theme.of(context).textTheme.caption.copyWith(fontSize: 30),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hero(
                        tag: "check$id",
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: BlocBuilder<GroceryListBloc, GroceryListState>(
                              cubit: bloc,
                              buildWhen: (previous, current) => current is CheckedChangedState && current.item.id == id,
                              builder: (context, state) {
                                var model = bloc.getItemOfId(id, listId);

                                return HeavyTouchButton(
                                  onPressed: () => bloc.updateItem(id, model.copyWith(checked: !model.checked), listId),
                                  child: ListItemCheckBox(checked: model?.checked ?? model.checked),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: animation,
                        child: NumberInput(
                          heroTag: "num$id",
                          fractionDigits: model.quantizationDecimalNumbersAmount,
                          quantize: model.quantization,
                          value: model.amount,
                          unit: model.unit,
                          onChanged: (value) => bloc.updateItem(id, model.copyWith(amount: value), listId),
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0.0, Curves.easeInCubic.transform(1 - animation.value) * MediaQuery.of(context).size.height * gr.invphi),
                      child: child,
                    ),
                    child: BlocBuilder<GroceryListBloc, GroceryListState>(
                        cubit: bloc,
                        buildWhen: (previous, current) =>
                            (current is ItemsChangedState && current.reboundPrototype == true && current.contains(id)) ||
                            (current is PrototypeRemovedState && current.prototype.id == bloc.getItemOfId(id, listId).boundPrototype.id),
                        builder: (context, state) {
                          var isPrototypeless = bloc.getItemOfId(id, listId).boundPrototype == null;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPrototypeless)
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListItemProperty(
                                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                          label: "Quantization",
                                          textFieldKey: quantizationKey,
                                          onEditingComplete: () {
                                            var value = double.tryParse(quantizationKey.currentState.controller.text);
                                            if (value == null || value < 0) {
                                              quantizationKey.currentState.controller.text = model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount);
                                              return;
                                            }

                                            var dot = quantizationKey.currentState.controller.text.lastIndexOf(RegExp(",|\\."));

                                            bloc.updateItem(
                                              id,
                                              model.copyWith(
                                                  quantization: value,
                                                  quantizationDecimalNumbersAmount: dot == -1 ? 0 : quantizationKey.currentState.controller.text.length - 1 - dot,
                                                  amount: (model.amount / value).round() * value),
                                              listId,
                                            );
                                          }),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      ListItemProperty(
                                          width: 75,
                                          label: "Unit",
                                          textFieldKey: unitKey,
                                          onEditingComplete: () => bloc.updateItem(id, model.copyWith(unit: unitKey.currentState.controller.text), listId)),
                                    ],
                                  ),
                                ),
                              if (isPrototypeless)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListItemProperty(
                                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                      label: "Price",
                                      textFieldKey: priceKey,
                                      onEditingComplete: () {
                                        bloc.updateItem(id, model.copyWith(price: double.parse(priceKey.currentState.controller.text)), listId);
                                      },
                                    ), // TODO: Make it constrain number of numbers in decimal fraction part to 2
                                    SizedBox(width: 15),
                                    ListItemProperty(
                                      width: 75,
                                      label: "Currency",
                                      textFieldKey: currencyKey,
                                      onEditingComplete: () => bloc.updateItem(id, model.copyWith(currency: currencyKey.currentState.controller.text), listId),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 30),
                              if (!isPrototypeless)
                                Text(
                                  "Bound to prototype",
                                  style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white70),
                                ),
                              SizedBox(height: 12),
                              if (!isPrototypeless)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Hero(
                                      tag: "title${model.id}",
                                      child: Text(
                                        model.title,
                                        style: Theme.of(context).textTheme.headline6,
                                      ),
                                    ),
                                    Text(
                                      "${model.boundPrototype.quantization} ${model.boundPrototype.unit}   ${model.boundPrototype.price} ${model.boundPrototype.currency}",
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          // TODO: Make buttons layout automatically
          bottom: 20,
          right: 16,
          left: 16,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 2), end: Offset(0.0, 0.0)).animate(animation),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocBuilder<GroceryListBloc, GroceryListState>(
                    cubit: bloc,
                    buildWhen: (previous, current) => current is ItemsChangedState, // TODO: Separate bound prototype change in a separeate state
                    builder: (context, state) {
                      var model = bloc.getItemOfId(id, listId) ?? (state as ItemDeletedState).removedItem;
                      var isPrototypeless = model.boundPrototype == null;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (isPrototypeless)
                            ActionButton(
                              onPressed: () {
                                var m = bloc.getItemOfId(id, listId);
                                var p = m.createPrototype();

                                bloc.addPrototype(p);
                                bloc.updateItem(id, m.copyWith(boundPrototype: p, updatePrototype: true), listId);
                              },
                              color: const Color(0xFFBF42C1),
                              icon: Icons.save_rounded,
                              title: "Create product",
                            ),
                          // SizedBox(width: 10),
                          if (isPrototypeless)
                            ActionButton(
                              onPressed: () {
                                bloc.updatePrototype(bloc.getItemOfId(id, listId).createPrototype()); // TODO
                              },
                              color: const Color(0xFF3ABD85),
                              icon: Icons.merge_type_rounded,
                              title: "Bind to product",
                            ),
                          if (!isPrototypeless)
                            ActionButton(
                              onPressed: () {
                                Navigator.push(context, ProductItemEditRoute(id: bloc.getItemOfId(id, listId).boundPrototype.id));
                              },
                              color: const Color(0xFFBF42C1),
                              icon: Icons.edit_outlined,
                              title: "Edit product",
                            ),
                          // SizedBox(width: 10),
                          if (!isPrototypeless)
                            ActionButton(
                              onPressed: () {
                                var m = bloc.getItemOfId(id, listId);

                                bloc.updateItem(id, m.boundPrototype.createGroceryItem().copyWith(id: id, amount: m.amount, boundPrototype: null, updatePrototype: true), listId);
                              },
                              color: const Color(0xFF3ABD85),
                              icon: Icons.merge_type_rounded,
                              title: "Unbind the product",
                            ),
                        ],
                      );
                    }),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      onPressed: () => bloc.addItem(bloc.getItemOfId(id, listId).copyWith(id: DateTime.now().toString()), listId),
                      color: const Color(0xFFEDB048),
                      icon: Icons.copy_outlined,
                      title: "Duplicate",
                    ),
                    // Spacer(),
                    ActionButton(
                      onPressed: () {
                        this.completed.then((value) => bloc.removeItem(id, listId));
                        Navigator.pop(context);
                      },
                      color: const Color(0xFFF4715D),
                      icon: Icons.delete,
                      title: "Delete",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get maintainState => true;
}
