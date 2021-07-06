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
    popped.then((_) => _animationController.animateBack(0.0, duration: const Duration(milliseconds: 600)));
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
    return Row(
      children: [
        Expanded(
          child: HeavyTouchButton(
            pressedScale: 0.85,
            onPressed: () async {
              var bloc = BlocProvider.of<GroceryListBloc>(context);

              _textField.unfocus();
              Navigator.pop(context);

              await completed;

              bloc.createItem(prototype.createGroceryItem());
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
          ),
        ),
        SizedBox(width: 10),
        HeavyTouchButton(
          pressedScale: 0.85,
          onPressed: () {
            BlocProvider.of<GroceryListBloc>(context).deletePrototype(prototype.id);
          },
          child: Icon(Icons.close_rounded),
        ),
      ],
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
                          hintStyle: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black54),
                        ),
                        style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              BlocBuilder<GroceryListBloc, GroceryListState>(
                cubit: bloc,
                buildWhen: (previous, current) =>
                    current is PrototypeRemovedState || current is PrototypesFetchedState || current is PrototypeAddedState,
                builder: (context, state) => AnimatedBuilder(
                  animation: _textEdContr,
                  builder: (context, child) => FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: bloc
                          .getRelevantPrototypes(15, _textEdContr.text)
                          .map((e) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: _buildPrototype(e, context),
                              ))
                          .toList(),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      color: const Color(0xFF17D368),
                      icon: Icons.save_rounded,
                      title: "Create product",
                      onPressed: () async {
                        if (_textEdContr.text == null || _textEdContr.text.isEmpty) return;

                        var prototype = GroceryPrototype(title: _textEdContr.text);
                        var newItem = prototype.createGroceryItem();

                        _textField.unfocus();
                        Navigator.pop(context);

                        await this.completed;

                        bloc.tryAddPrototype(prototype);
                        bloc.createItem(newItem);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      color: const Color(0xFF92C95B),
                      icon: Icons.add_rounded,
                      title: "Create without product",
                      onPressed: () {
                        if (_textEdContr.text == null || _textEdContr.text.isEmpty) return;

                        var newItem = ProductlessGroceryItem(title: _textEdContr.text, amount: 1);

                        bloc.createItem(newItem);

                        _textField.unfocus();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarPersistentHeaderDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}