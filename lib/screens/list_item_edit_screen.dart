import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/list_item_property.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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

  Widget _buildActionButton({
    @required VoidCallback onPressed,
    @required Color color,
    @required IconData icon,
    @required String title,
    @required BuildContext context,
  }) {
    return HeavyTouchButton(
      pressedScale: 0.9,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1.2,
            color: color.withRangedHsvSaturation(0.8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 8,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.button,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var initialModel = bloc.items[id];
    var titleEdContr = TextEditingController(text: initialModel.title);
    var quantizationEdContr =
        TextEditingController(text: initialModel.quantization.toStringAsFixed(initialModel.quantizationDecimalNumbersAmount));
    var unitEdContr = TextEditingController(text: initialModel.unit);
    var priceEdContr = TextEditingController(text: initialModel.price.toStringAsFixed(2));
    var currencyEdContr = TextEditingController(text: initialModel.currency);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: animation.value * 2,
              sigmaY: animation.value * 2,
            ),
            child: child,
          ),
          child: ColoredBox(
            color: Colors.transparent,
            child: SizedBox.expand(),
          ),
        ),
        FadeTransition(
          opacity: _animationController,
          child: ColoredBox(
            color: Colors.black54,
            child: SizedBox.expand(),
          ),
        ),
        BlocProvider<GroceryListBloc>(
          create: (context) => bloc,
          child: SafeArea(
            child: BlocBuilder<GroceryListBloc, GroceryListState>(
              cubit: bloc,
              buildWhen: (previous, current) {
                if (current is ItemChangedState && current.id == id) {
                  var model = current.items[current.id];
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
                var model = bloc.items[id] ?? (state as ItemDeletedState).removedItem;

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
                          child: HeavyTouchButton(
                            onPressed: () => bloc.updateItem(id, bloc.items[id].copyWith(checked: !bloc.items[id].checked)),
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: BlocBuilder<GroceryListBloc, GroceryListState>(
                                  cubit: bloc,
                                  buildWhen: (previous, current) => current is CheckedChangedState && current.id == id,
                                  builder: (context, state) => ListItemCheckBox(checked: bloc?.items[id]?.checked ?? model.checked),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Hero(
                          tag: "num$id",
                          child: NumberInput(
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
                    SizedBox(
                      height: 500,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 0,
          left: 0,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 2), end: Offset(0.0, 0.0)).animate(animation),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 2,
                  child: SizedBox(),
                ),
                Flexible(
                  flex: 5,
                  child: _buildActionButton(
                    onPressed: () => bloc.createItem(bloc.items[id].copyWith(id: DateTime.now().toString())),
                    color: const Color(0xfffaca69),
                    icon: Icons.copy_outlined,
                    title: "Duplicate",
                    context: context,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(),
                ),
                Flexible(
                  flex: 5,
                  child: _buildActionButton(
                    onPressed: () {
                      this.completed.then((value) => bloc.deleteItem(id));
                      Navigator.pop(context);
                    },
                    color: const Color(0xfffa8169),
                    icon: Icons.delete,
                    title: "Delete",
                    context: context,
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: SizedBox(),
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
