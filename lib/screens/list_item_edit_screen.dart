import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/list_item_property.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:my_utilities/color_utils.dart';
import '../utils/golden_ration_utils.dart' as gr;

class ListItemEditRoute extends PageRoute with TickerProviderMixin {
  final GroceryListBloc bloc;
  final String id;

  ListItemEditRoute({this.bloc, this.id});

  ScrollController _scrollController;
  AnimationController _animationController;

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
    var initialModel = bloc.getItemOfId(id);
    var titleEdContr = TextEditingController(text: initialModel.title);
    var quantizationEdContr =
        TextEditingController(text: initialModel.quantization.toStringAsFixed(initialModel.quantizationDecimalNumbersAmount));
    var unitEdContr = TextEditingController(text: initialModel.unit);
    var priceEdContr = TextEditingController(text: initialModel.price.toStringAsFixed(2));
    var currencyEdContr = TextEditingController(text: initialModel.currency);

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
            child: BlocBuilder<GroceryListBloc, GroceryListState>(
              cubit: bloc,
              buildWhen: (previous, current) {
                if (current is ItemChangedState && current.id == id) {
                  var model = current.item;
                  return model.title != titleEdContr.text ||
                      model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount) != quantizationEdContr.text ||
                      model.unit != unitEdContr.text ||
                      model.price.toStringAsFixed(2) != priceEdContr.text ||
                      model.currency != currencyEdContr.text;
                } else if (current is ItemDeletedState) {
                  return current.removedItem.id == id;
                }
                return false;
              },
              builder: (context, state) {
                var model = bloc.getItemOfId(id) ?? (state as ItemDeletedState).removedItem;

                return ListView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (1 - gr.invphi),
                    ),
                    SizedBox(
                      width: 300,
                      height: 30,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Hero(
                          tag: "title$id",
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              textAlign: TextAlign.center,
                              scrollPadding: EdgeInsets.zero,
                              decoration:
                                  InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(6), hintText: "Item title"),
                              cursorWidth: 2,
                              cursorRadius: Radius.circular(2),
                              controller: titleEdContr,
                              onEditingComplete: () => bloc.updateItem(id, model.copyWith(title: titleEdContr.text)),
                              onSubmitted: (value) => FocusScope.of(context).unfocus(),
                              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 30),
                            ),
                          ),
                        ),
                      ),
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
                                  var model = bloc.getItemOfId(id);

                                  return HeavyTouchButton(
                                    onPressed: () => bloc.updateItem(id, model.copyWith(checked: !model.checked)),
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
                            onChanged: (value) => bloc.updateItem(id, model.copyWith(amount: value)),
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) => Transform.translate(
                        offset:
                            Offset(0.0, Curves.easeInCubic.transform(1 - animation.value) * MediaQuery.of(context).size.height * gr.invphi),
                        child: child,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListItemProperty(
                                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                    label: "Quantization",
                                    textEditingController: quantizationEdContr,
                                    onEditingComplete: () {
                                      var value = double.tryParse(quantizationEdContr.text);
                                      if (value == null || value < 0) {
                                        quantizationEdContr.text =
                                            model.quantization.toStringAsFixed(model.quantizationDecimalNumbersAmount);
                                        return;
                                      }

                                      var dot = quantizationEdContr.text.lastIndexOf(RegExp(",|\\."));

                                      bloc.updateItem(
                                        id,
                                        model.copyWith(
                                            quantization: value,
                                            quantizationDecimalNumbersAmount: dot == -1 ? 0 : quantizationEdContr.text.length - 1 - dot,
                                            amount: (model.amount / value).round() * value),
                                      );
                                    }),
                                SizedBox(
                                  width: 15,
                                ),
                                ListItemProperty(
                                    width: 75,
                                    label: "Unit",
                                    textEditingController: unitEdContr,
                                    onEditingComplete: () => bloc.updateItem(id, model.copyWith(unit: unitEdContr.text))),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListItemProperty(
                                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                label: "Price",
                                textEditingController: priceEdContr,
                                onEditingComplete: () {
                                  bloc.updateItem(id, model.copyWith(price: double.parse(priceEdContr.text)));
                                },
                              ), // TODO: Make it constrain number of numbers in decimal fraction part to 2
                              SizedBox(width: 15),
                              ListItemProperty(
                                width: 75,
                                label: "Currency",
                                textEditingController: currencyEdContr,
                                onEditingComplete: () => bloc.updateItem(id, model.copyWith(currency: currencyEdContr.text)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 500,
                    // ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 16,
          left: 16,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 2), end: Offset(0.0, 0.0)).animate(animation),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ActionButton(
                  onPressed: () {
                    bloc.updatePrototypeOfTitle(bloc.getItemOfId(id).createPrototype());
                  },
                  color: const Color(0xFFBF42C1),
                  icon: Icons.update_rounded,
                  title: "Update in history",
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      onPressed: () => bloc.createItem(bloc.getItemOfId(id).copyWith(id: DateTime.now().toString())),
                      color: const Color(0xFFEDB048),
                      icon: Icons.copy_outlined,
                      title: "Duplicate",
                    ),
                    // Spacer(),
                    ActionButton(
                      onPressed: () {
                        this.completed.then((value) => bloc.deleteItem(id));
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

// class ItemListEditMenu extends StatefulWidget {
//   final int index;
//   final GroceryListBloc bloc;
//   final AnimationController controller;

//   const ItemListEditMenu({Key key, this.index, this.bloc, this.controller}) : super(key: key);

//   @override
//   _ItemListEditMenuState createState() => _ItemListEditMenuState();
// }

// class _ItemListEditMenuState extends State<ItemListEditMenu> with TickerProviderStateMixin {
//   ScrollController _scrollController;

//   @override
//   void initState() {
//     _scrollController = ScrollController()..addListener(_handleScroll);
//     controller.addListener(() {
//       print(controller);
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _handleScroll() {
//     if (_scrollController.offset < -60) {
//       controller
//           ?.animateBack((40 + _scrollController.offset.clamp(-40, 0)) / 40, duration: const Duration(milliseconds: 0))
//           .then((value) => Navigator.pop(context));
//       Navigator.of(context).pop();
//       _scrollController.removeListener(_handleScroll);
//     } else {
//       controller?.animateBack((40 + _scrollController.offset.clamp(-40, 0)) / 40, duration: const Duration(milliseconds: 0));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var titleEdContr = TextEditingController(text: bloc.items[index].title);

//     return BlocProvider<GroceryListBloc>(
//       create: (context) => bloc,
//       child: SafeArea(
//         child: BlocBuilder<GroceryListBloc, GroceryListState>(
//           cubit: bloc,
//           buildWhen: (previous, current) => current is GroceryListState,
//           builder: (context, state) {
//             var model = bloc.items[index];

//             return ListView(
//               controller: _scrollController,
//               physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * (1 - gr.invphi),
//                 ),
//                 SizedBox(
//                   width: 300,
//                   height: 30,
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Hero(
//                       tag: "title${index}",
//                       child: Material(
//                         color: Colors.transparent,
//                         child: TextField(
//                           textAlign: TextAlign.center,
//                           scrollPadding: EdgeInsets.zero,
//                           decoration:
//                               InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(4.5), hintText: "Item title"),
//                           cursorWidth: 2,
//                           cursorRadius: Radius.circular(2),
//                           controller: titleEdContr,
//                           onEditingComplete: () => bloc.updateItem(index, model.copyWith(title: titleEdContr.text)),
//                           onSubmitted: (value) => FocusScope.of(context).unfocus(),
//                           style: Theme.of(context).textTheme.caption.copyWith(fontSize: 28),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Hero(
//                       tag: "check${index}",
//                       child: HeavyTouchButton(
//                         onPressed: () => bloc.updateItem(index, model.copyWith(checked: !model.checked)),
//                         child: ColoredBox(
//                           color: Colors.transparent,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8),
//                             child: ListItemCheckBox(checked: model.checked),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Hero(
//                       tag: "num${index}",
//                       child: NumberInput(
//                         fractionDigits: model.integerQuantization ? 0 : 3,
//                         quantize: 0.6,
//                         value: model.amount,
//                         unit: model.unit,
//                         onChanged: (value) => bloc.updateItem(index, model.copyWith(amount: value)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 500,
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
