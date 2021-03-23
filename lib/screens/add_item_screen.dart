import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:my_utilities/color_utils.dart';

class AddItemScreen<T> extends PageRoute<T> with TickerProviderMixin {
  @override
  Color get barrierColor => Colors.transparent;

  bool get opaque => false;

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 600);

  ScrollController _scrollController;
  AnimationController _animationController;
  FocusNode _textField;
  TextEditingController _textEdContr;

  @override
  void install() {
    _animationController = AnimationController(vsync: this)..animateTo(1.0, duration: const Duration(milliseconds: 600));
    _scrollController = ScrollController()..addListener(_handleScroll);
    _textField = FocusNode();
    _textEdContr = TextEditingController();
    super.install();
  }

  @override
  void dispose() {
    disposeTickers();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _textEdContr.dispose();
    controller.removeStatusListener(_handleControllerStatus);
    super.dispose();
  }

  @override
  AnimationController createAnimationController() {
    return super.createAnimationController()..addStatusListener(_handleControllerStatus);
  }

  void _handleControllerStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(Duration(milliseconds: 20)).then((value) => _textField.requestFocus());
    }
  }

  void _handleScroll() {
    if (_scrollController.offset < -70) {
      _scrollController.removeListener(_handleScroll);
      navigator.pop();
    } else if (_scrollController.offset < 0) {
      _animationController.value = (60 + _scrollController.offset) / 60;
    }
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

  Widget _buildPrototype(GroceryPrototype prototype, BuildContext context) {
    return HeavyTouchButton(
      pressedScale: 0.85,
      onPressed: () {
        _textField.unfocus();
        BlocProvider.of<GroceryListBloc>(context).createItem(prototype.createGroceryItem());
        Navigator.pop(context);
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        shadowColor: Colors.transparent,
        type: MaterialType.button,
        color: const Color.fromRGBO(40, 40, 40, 0.7),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            prototype.title,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _animationController.value * 1.8, sigmaY: _animationController.value * 1.8),
              child: ColoredBox(
                color: Colors.black.withOpacity(_animationController.value * 0.5),
                child: child,
              ),
            ),
            child: SizedBox.expand(),
          ),
          ListView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SafeArea(
                  child: Hero(
                    tag: "addItem",
                    child: Material(
                      color: const Color.fromARGB(255, 250, 250, 250),
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      type: MaterialType.button,
                      child: TextField(
                        onSubmitted: (value) => _textField.unfocus(),
                        controller: _textEdContr,
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _textField,
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          hintText: "+  Create item",
                          hintStyle: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black38),
                        ),
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 2), end: Offset(0, 0)).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: AnimatedBuilder(
                    animation: _textEdContr,
                    builder: (context, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      key: ValueKey(_textEdContr.text),
                      children: bloc
                          .getRelevantPrototypes(15, _textEdContr.text)
                          .map((e) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: _buildPrototype(e, context),
                              ))
                          .toList(), // TODO: Rebuild as the text is typed
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 20,
            left: 20,
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset(0, 2.0), end: Offset(0, 0)).animate(animation),
              child: ActionButton(
                color: const Color.fromARGB(255, 40, 210, 110),
                icon: Icons.add_rounded,
                title: "Confirm item",
                onPressed: () async {
                  var newItem = GroceryItem(title: _textEdContr.text);

                  bloc.createItem(newItem);

                  _textField.unfocus();
                  Navigator.pop(context);

                  await this.completed; 
                  bloc.tryAddPrototype(newItem.createPrototype());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
