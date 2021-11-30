import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/list_item_check_box.dart';
import 'package:grocery_list/widgets/beautiful_text_field.dart';
import 'package:grocery_list/widgets/grocery_item_amount.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import 'package:my_utilities/color_utils.dart';
import '../utils/golden_ration_utils.dart' as gr;

class ProductItemEditRoute extends PageRoute with TickerProviderMixin {
  final String id;

  ProductItemEditRoute({@required this.id});

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
    var bloc = BlocProvider.of<GroceryListBloc>(context);
    var model = bloc.prototypes.firstWhere((e) => e.id == id);
    // model = bloc.prototypes.firstWhere((e) => e.id == id);

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
              listener: (previous, current) {
                if (current is PrototypeChangedState && current.updatedPrototypes.id == id) {
                  model = current.updatedPrototypes;
                  titleKey.currentState.controller.text = model.title;
                  quantizationKey.currentState.controller.text = model.quantization.toStringAsFixed(model.quantizationFractionDigits);
                  unitKey.currentState.controller.text = model.unit;
                  priceKey.currentState.controller.text = model.price.toStringAsFixed(2);
                  currencyKey.currentState.controller.text = model.currency;
                }
                return false;
              },
              child: ListView(
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
                          child: SmartTextField(
                            textCapitalization: TextCapitalization.sentences,
                            textAlign: TextAlign.center,
                            scrollPadding: EdgeInsets.zero,
                            decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(6), hintText: "Item title"),
                            cursorWidth: 2,
                            cursorRadius: Radius.circular(2),
                            key: titleKey,
                            onEditingComplete: (_) => bloc.updatePrototype(model.copyWith(title: titleKey.currentState.controller.text)),
                            onSubmitted: (value) => FocusScope.of(context).unfocus(),
                            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0.0, Curves.easeInCubic.transform(1 - animation.value) * MediaQuery.of(context).size.height * gr.invphi),
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
                              BeautifulTextField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                  label: "Quantization",
                                  textFieldKey: quantizationKey,
                                  onEditingComplete: (_) {
                                    var value = double.tryParse(quantizationKey.currentState.controller.text);
                                    if (value == null || value < 0) {
                                      quantizationKey.currentState.controller.text = model.quantization.toStringAsFixed(model.quantizationFractionDigits);
                                      return;
                                    }

                                    var dot = quantizationKey.currentState.controller.text.lastIndexOf(RegExp(",|\\."));

                                    bloc.updatePrototype(
                                      model = model.copyWith(
                                        quantization: value,
                                        quantizationDecimalNumbersAmount: dot == -1 ? 0 : quantizationKey.currentState.controller.text.length - 1 - dot,
                                      ),
                                    );
                                  }),
                              SizedBox(
                                width: 15,
                              ),
                              BeautifulTextField(
                                  width: 75,
                                  label: "Unit",
                                  textFieldKey: unitKey,
                                  onEditingComplete: (_) {
                                    bloc.updatePrototype(model.copyWith(unit: unitKey.currentState.controller.text));
                                  }),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BeautifulTextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                              label: "Price",
                              textFieldKey: priceKey,
                              onEditingComplete: (_) {
                                bloc.updatePrototype(model.copyWith(price: double.parse(priceKey.currentState.controller.text)));
                              },
                            ), // TODO: Make it constrain number of numbers in decimal fraction part to 2
                            SizedBox(width: 15),
                            BeautifulTextField(
                              width: 75,
                              label: "Currency",
                              textFieldKey: currencyKey,
                              onEditingComplete: (_) => bloc.updatePrototype(model.copyWith(currency: currencyKey.currentState.controller.text)),
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
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 16,
          left: 16,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 2), end: Offset(0.0, 0.0)).animate(animation),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  onPressed: () => bloc.addPrototype(bloc.getPrototypeOfId(id).copyWith(id: DateTime.now().toString())),
                  color: const Color(0xFFEDB048),
                  icon: Icons.copy_outlined,
                  title: "Duplicate",
                ),
                // Spacer(),
                ActionButton(
                  onPressed: () {
                    this.completed.then((value) => bloc.removeProduct(id));
                    Navigator.pop(context);
                  },
                  color: const Color(0xFFF4715D),
                  icon: Icons.delete,
                  title: "Delete",
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
