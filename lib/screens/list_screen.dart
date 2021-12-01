import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/add_item_screen.dart';
import 'package:grocery_list/screens/list_settings_screen.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/action_button.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/grocery_list_item.dart';
import 'package:grocery_list/widgets/grocery_list_items_expansion_controller.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/pop_on_swipe.dart';
import 'package:grocery_list/widgets/unfocus_on_tap.dart';
import 'package:my_utilities/color_utils.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:rive/rive.dart';
import '../utils/golden_ration_utils.dart' as gr;

import '../bloc/grocery_list_bloc.dart';
import '../bloc/grocery_list_bloc.dart';

class ListScreen extends PageRoute with PopOnSwipeRightRouteMixin {
  final String listId;

  ListScreen({this.listId});

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => "";

  GroceryItemExpansionController _expansionController;

  Widget _buildBottomBarButton(BuildContext context, IconData icon, Color color, String tooltip, VoidCallback onPressed) => Tooltip(
        message: tooltip,
        child: HeavyTouchButton(
          onPressed: onPressed,
          child: PhysicalModel(
            color: color,
            elevation: 3,
            borderRadius: BorderRadius.circular(60),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(3), width: 1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(icon),
              ),
            ),
          ),
        ),
      );

  @override
  void install() {
    super.install();
    _expansionController = GroceryItemExpansionController();
  }

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    var bloc = BlocProvider.of<GroceryListBloc>(context);
    var screenWidth = MediaQuery.of(context).size.width;

    return PopOnSwipeRight(
      key: popOnSwipeRight,
      child: UnfocusOnTap(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(animation),
            child: Material(
              elevation: 4,
              type: MaterialType.canvas,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: [
                  BlocBuilder<GroceryListBloc, GroceryListState>(
                    // The list
                    buildWhen: (prev, state) {
                      return ((state is ItemDeletedState || state is ItemCreatedState) && (state as WithinListState).listId == listId) || state is ItemsFetchedState;
                    },
                    cubit: bloc,
                    builder: (context, state) => ImplicitlyAnimatedReorderableList<GroceryItem>(
                      padding: EdgeInsets.only(top: 100),
                      onReorderStarted: (item, index) => _expansionController.expandedGroceryItemId = null,
                      onReorderFinished: (item, from, to, newItems) => bloc.moveItem(from, to, listId),
                      areItemsTheSame: (a, b) => a.id == b.id,
                      itemBuilder: (context, animation, item, i) {
                        return Reorderable(
                          key: ValueKey(item.id),
                          child: FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: Handle(
                                delay: Duration(milliseconds: 400),
                                child: GroceryListItem(
                                  fallbackModel: item,
                                  key: ValueKey(item.id),
                                  listId: listId,
                                  expansionController: _expansionController,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      items: bloc.getListOfId(listId).items,
                      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    ),
                  ),
                  Positioned(
                    // Back button
                    left: 30,
                    top: MediaQuery.of(context).padding.top + 20,
                    child: HeavyTouchButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    // Bottom buttons
                    bottom: 20,
                    left: 30,
                    right: 30,
                    child: Row(
                      children: [
                        Expanded(
                          // Searchbar
                          child: Hero(
                            tag: "addItem",
                            child: HeavyTouchButton(
                              onPressed: () {
                                if (ModalRoute.of(context).isCurrent) {
                                  print("Tap");
                                  Navigator.push(context, AddItemScreen(listId, bloc));
                                }
                              },
                              pressedScale: 0.9,
                              child: Material(
                                color: const Color.fromARGB(255, 250, 250, 250),
                                elevation: 6,
                                borderRadius: BorderRadius.circular(8),
                                type: MaterialType.button,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Text(
                                    "+  Create item",
                                    style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        _buildBottomBarButton(
                          // Editing mode button
                          context,
                          Icons.edit_rounded,
                          Theme.of(context).cardColor,
                          "Editing Mode",
                          () {},
                        ),
                        SizedBox(width: 10),
                        Tooltip(
                          // List settings button
                          message: "List settings",
                          child: HeavyTouchButton(
                            onPressed: () => Navigator.of(context).push(ListSettingsScreen(listId: listId)),
                            child: PhysicalModel(
                              color: Theme.of(context).cardColor,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(60),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(3), width: 1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Hero(
                                    tag: "list_settings_screen_back_button",
                                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        RotationTransition(
                                          turns: Tween(begin: 0.0, end: 0.7).animate(animation),
                                          child: FadeTransition(
                                            opacity: ReverseAnimation(animation),
                                            child: Icon(Icons.settings_rounded),
                                          ),
                                        ),
                                        RotationTransition(
                                          turns: Tween(begin: -0.7, end: 0.0).animate(animation),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: Icon(Icons.arrow_back_rounded),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.settings_rounded),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;
}
