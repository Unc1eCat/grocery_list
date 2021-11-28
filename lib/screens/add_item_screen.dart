import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:my_utilities/color_utils.dart';

class AddItemScreen<T> extends PageRoute<T> with TickerProviderMixin {
  final String listId;

  AddItemScreen(this.listId, this.bloc);

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
  StreamController<List<Widget>> _reloadSearchResultsStreamController;
  Timer _reloadSearchResultsTimer;
  GroceryListBloc bloc;

  void _startSearchReloadTimer() {
    _reloadSearchResultsTimer?.cancel();
    _reloadSearchResultsTimer = Timer(
        Duration(milliseconds: 700),
        () => _reloadSearchResultsStreamController.add(bloc
            .getSearchResults(_textEdContr.text, listId)
            .map((e) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: e,
                ))
            .toList()));
  }

  @override
  void install() {
    _animationController = AnimationController(vsync: this)..animateTo(1.0, duration: const Duration(milliseconds: 600));
    _scrollController = ScrollController()..addListener(_handleScroll);
    _textField = FocusNode();
    _textEdContr = TextEditingController();
    _reloadSearchResultsStreamController = StreamController(sync: false);
    _textEdContr.addListener(() => _startSearchReloadTimer());
    _startSearchReloadTimer();
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
    _reloadSearchResultsStreamController.close();
    _reloadSearchResultsTimer.cancel();
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

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _animationController.value * 3, sigmaY: _animationController.value * 3),
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
              FadeTransition(
                opacity: _animationController,
                child: StreamBuilder<List<Widget>>(
                  stream: _reloadSearchResultsStreamController.stream,
                  initialData: [],
                  builder: (context, snap) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                      child: Column(
                        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: snap.data,
                      ),
                    );
                  },
                ),
              ),
            ],
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
