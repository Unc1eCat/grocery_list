import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/screens/general_list_settings_tab.dart';
import 'package:grocery_list/screens/tags_list_settings_tab.dart';
import 'package:grocery_list/utils/scroll_behavior.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/blurry_faded_background.dart';
import 'package:grocery_list/widgets/colored_tab.dart';
import 'package:grocery_list/widgets/faded_borders_box.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/pop_on_swipe.dart';
import 'package:path/path.dart';

class ListSettingsScreen extends PageRoute with TickerProviderMixin {
  final String listId;

  AnimationController _animationController;
  ScrollController _scrollController;
  TabController _tabController;

  ListSettingsScreen({@required this.listId});

  @override
  void install() {
    _animationController = AnimationController(vsync: this)..animateTo(1.0, duration: const Duration(milliseconds: 500));
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 4);
    _scrollController = ScrollController()..addListener(_handleScroll);
    super.install();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    disposeTickers();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset < -70) {
      _scrollController.removeListener(_handleScroll);
      navigator.pop();
    } else if (_scrollController.offset < 0) {
      _animationController.value = (60 + _scrollController.offset) / 60;
    }
  }

  Widget _buildTabBarButton(String title, int tabIndex) => HeavyTouchButton(
        onPressed: () => _tabController.animateTo(tabIndex),
        child: Align(
          alignment: Alignment.center,
          child: ColoredTab(
            controller: _tabController,
            index: tabIndex,
            text: title,
            unselectedColor: Colors.grey[500],
            selectedColor: Colors.white,
          ),
        ),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return BlurryFadedBackground(
      controller: _animationController,
      child: Stack(
        children: [
          FadeTransition(
            opacity: _animationController,
            child: TabBarView(
              controller: _tabController,
              children: [
                GeneralListSettingsTab(
                  scrollController: _scrollController,
                  listId: listId,
                ),
                TagsListSettingsTab(
                  scrollController: _scrollController,
                  listId: listId,
                ),
                GeneralListSettingsTab(
                  scrollController: _scrollController,
                ),
                GeneralListSettingsTab(
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Padding(
              // Bottom buttons and tabs
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                height: 80,
                child: FadeTransition(
                  opacity: _animationController,
                  child: FadedBordersBox(
                    left: 0.1,
                    right: 0.1,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      isScrollable: true,
                      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      tabs: [
                        _buildTabBarButton("General", 0),
                        _buildTabBarButton("Tags", 1),
                        _buildTabBarButton("Members", 2),
                        _buildTabBarButton("Roles", 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Color get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);
}
