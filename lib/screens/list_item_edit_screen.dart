import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/number_input.dart';
import 'package:my_utilities/color_utils.dart';
import '../utils/golden_ration_utils.dart' as gr;

class ListItemEditRoute extends PageRoute {
  final GroceryListBloc bloc;
  final int index;

  ListItemEditRoute({this.bloc, this.index});

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 600);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => "";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var titleEdContr = TextEditingController(text: bloc.items[index].title);

    return Stack(
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.8,
              sigmaY: 1.8,
            ),
            child: ColoredBox(
              color: Colors.black87,
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
                          tag: "title$index",
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              textAlign: TextAlign.center,
                              scrollPadding: EdgeInsets.zero,
                              decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(4.5), hintText: "Item title"),
                              cursorWidth: 2,
                              cursorRadius: Radius.circular(2),
                              controller: titleEdContr,
                              onEditingComplete: () => bloc.updateItem(index, model.copyWith(title: titleEdContr.text)),
                              onSubmitted: (value) => FocusScope.of(context).unfocus(),
                              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 28),
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
                        Hero(
                          tag: "num$index",
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
