import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_utilities/color_utils.dart';
import '../utils/golden_ration_utils.dart' as gr;

class ListItemEditRoute extends PageRoute with TickerProviderMixin {
  final GroceryListBloc bloc;
  final int index;

  ListItemEditRoute({this.bloc, this.index});

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
      print("sgds");
    } else if (_scrollController.offset < 0) {
      _animationController.value = (60 + _scrollController.offset).clamp(0, 60) / 60;
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

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var titleEdContr = TextEditingController(text: bloc.items[index].title);

    return Stack(
      children: [
        FadeTransition(
          opacity: _animationController,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.8,
              sigmaY: 1.8,
            ),
            child: ColoredBox(
              color: Colors.black54,
              child: SizedBox.expand(),
            ),
          ),
        ),
        BlocProvider<GroceryListBloc>(
          create: (context) => bloc,
          child: SafeArea(
            child: BlocBuilder<GroceryListBloc, GroceryListState>(
              cubit: bloc,
              buildWhen: (previous, current) => current is GroceryListState,
              builder: (context, state) {
                var model = bloc.items[index];

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
                          tag: "title${index}",
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              textAlign: TextAlign.center,
                              scrollPadding: EdgeInsets.zero,
                              decoration:
                                  InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(9.5), hintText: "Item title"),
                              cursorWidth: 2,
                              cursorRadius: Radius.circular(2),
                              controller: titleEdContr,
                              onEditingComplete: () => bloc.updateItem(index, model.copyWith(title: titleEdContr.text)),
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
                          tag: "check${index}",
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
                        Hero(
                          tag: "num${index}",
                          child: NumberInput(
                            fractionDigits: model.integerQuantization ? 0 : 3,
                            quantize: 0.6,
                            value: model.amount,
                            unit: model.unit,
                            onChanged: (value) => bloc.updateItem(index, model.copyWith(amount: value)),
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0.0, (1 - animation.value) * MediaQuery.of(context).size.height * gr.invphi),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.green,
                            height: 200,
                            width: 200,
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
