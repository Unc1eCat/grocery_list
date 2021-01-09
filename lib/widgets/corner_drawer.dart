import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import '../utils/golden_ration_utils.dart' as gr;
import 'package:my_utilities/color_utils.dart';
import 'package:my_utilities/math_utils.dart' as math;

class CornerDrawer extends StatefulWidget {
  final double drawerWidth;
  final Widget screen;
  final Widget expandedChild;
  final Widget opennedButton;
  final Widget closedButton;
  final Color color;
  final Color backgroundColor;
  final BorderRadius screenBorderRadius;
  final Duration drawerAnimationDuration;
  final double buttonRadius;
  final Duration extendedChildAnimationDuration;
  final AnimatedTransitionBuilder extendedChildTransitionBuilder;

  /// Size of the butotn in the closed position
  final Size buttonSize;

  /// Elevation of the screen
  final double elevation;

  /// How much should the screeen be covered in black when the drawer is open: 0.0 = no fade, 1.0 = fully black(not recommended)
  final double fadeAmount;

  /// How much should the screen scale down: 0.0 = no scale down, 1.0 = disappear
  final double scaleDownAmount;

  /// How much should the drawer overlap previous screen: 0.0 = no overlap, 1.0 = fully cover.
  /// Specify a negative nubmer to leave some space between the screen and the drawer
  final double overlap;

  Duration get fullAniamtionDuration => drawerAnimationDuration + extendedChildAnimationDuration;

  CornerDrawer({
    @required this.screen,
    @required this.expandedChild,
    @required this.opennedButton,
    @required this.closedButton,
    this.drawerWidth,
    this.overlap = 0.0,
    this.scaleDownAmount = 0.1,
    this.color,
    this.backgroundColor,
    this.elevation = 3,
    this.fadeAmount = 0.6,
    this.screenBorderRadius,
    this.drawerAnimationDuration = const Duration(milliseconds: 300),
    this.buttonSize = const Size(60, 80),
    this.buttonRadius = 12,
    this.extendedChildAnimationDuration = const Duration(milliseconds: 100),
    this.extendedChildTransitionBuilder,
  });

  // Widget _defaultExtendedChildTransitionBuilder(BuildContext context, Animation<double> animation, Widget child) => child;

  @override
  _CornerDrawerState createState() => _CornerDrawerState();

  static _CornerDrawerState of(BuildContext context) => context.findAncestorStateOfType<_CornerDrawerState>();
}

class _CornerDrawerState extends State<CornerDrawer> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _slideAniamtion;
  Animation<double> _scaleAniamtion;

  /// Aniamtion representing oppening and closing of the drawer
  Animation<double> drawerAnimation;

  /// The animation representing appearing and disappearing of the extended child
  Animation<double> extendedChildAniamtion;

  /// Opens the drawer
  void openDrawer() {
    _controller.animateTo(1.0);
  }

  /// Closes the drawer
  void closeDrawer() {
    _controller.animateBack(0.0);
  }

  /// The animation composed of sequence of the extended child and the drawer animations, full animation
  Animation<double> get animation => _controller.view;

  double get _drawerWidth => widget.drawerWidth ?? MediaQuery.of(context).size.width * (1 - gr.invphi * gr.invphi);

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.fullAniamtionDuration);
    // ..addStatusListener((status) {
    //   print(status);
    // });

    drawerAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, widget.drawerAnimationDuration.inMilliseconds / widget.fullAniamtionDuration.inMilliseconds),
    );
    extendedChildAniamtion = CurvedAnimation(
      parent: _controller,
      curve: Interval(widget.drawerAnimationDuration.inMilliseconds / widget.fullAniamtionDuration.inMilliseconds, 1.0),
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _slideAniamtion = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-_drawerWidth * (1.0 - widget.overlap) / MediaQuery.of(context).size.width, 0),
    ).animate(drawerAnimation);
    _scaleAniamtion = Tween<double>(
      begin: 1.0,
      end: 1.0 - widget.scaleDownAmount,
    ).animate(drawerAnimation);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenBorderRadius = widget.screenBorderRadius ?? BorderRadius.circular(8);

    return Stack(
      children: [
        ColoredBox(
          color: Theme.of(context).backgroundColor,
          child: SizedBox.expand(),
        ),
        SlideTransition(
          position: _slideAniamtion,
          child: ScaleTransition(
            scale: _scaleAniamtion,
            child: DecoratedBoxTransition(
              position: DecorationPosition.foreground,
              decoration: DecorationTween(
                begin: BoxDecoration(
                  color: Colors.transparent,
                ),
                end: BoxDecoration(
                  color: Colors.black.withOpacity(widget.fadeAmount),
                  borderRadius: screenBorderRadius,
                ),
              ).animate(drawerAnimation),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: screenBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black.withOpacity(math.clip(widget.elevation / 7, 0.45, 1.0)), // TODO: Make better elevation
                      spreadRadius: widget.elevation / 3,
                    ),
                  ],
                ),
                child: widget.screenBorderRadius == BorderRadius.zero
                    ? widget.screen
                    : AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => ClipRRect(
                          borderRadius: BorderRadius.lerp(BorderRadius.zero, screenBorderRadius, _controller.value),
                          child: child,
                        ),
                        child: widget.screen,
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _CornerDrawerButton(),
        ),
      ],
    );
  }
} // TODO: Implement it with render boxes!!!!

class _CornerDrawerButton extends StatelessWidget {
  _CornerDrawerButton();

  @override
  Widget build(BuildContext context) {
    var cornerDrawer = context.findAncestorStateOfType<_CornerDrawerState>();
    var buttonDecorationShadows = [
      BoxShadow(
        blurRadius: 4,
        color: cornerDrawer.widget.color?.withOpacity(0.35) ?? Theme.of(context).primaryColor.withOpacity(0.35),
        spreadRadius: 1,
      ),
    ];
    var buttonDecorationGradient = LinearGradient(
      colors: [
        cornerDrawer.widget.color ?? Theme.of(context).accentColor,
        cornerDrawer.widget.color?.withRotatedHsvHue(40)?.withRangedHsvSaturation(0.9) ??
            Theme.of(context).accentColor.withRotatedHsvHue(40).withRangedHsvSaturation(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedBuilder(
      animation: cornerDrawer.extendedChildAniamtion,
      builder: (context, ch) {
        Widget child;

        if (cornerDrawer.drawerAnimation.status == AnimationStatus.forward) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Opacity(
                  opacity: 1.0 - cornerDrawer.drawerAnimation.value,
                  child: cornerDrawer.widget.closedButton,
                ),
              ),
              Opacity(
                opacity: cornerDrawer.drawerAnimation.value,
                child: cornerDrawer.widget.opennedButton,
              ),
            ],
          );
        } else if (cornerDrawer.drawerAnimation.status == AnimationStatus.reverse) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1.0 - cornerDrawer.drawerAnimation.value,
                child: cornerDrawer.widget.closedButton,
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: cornerDrawer.drawerAnimation.value,
                  child: cornerDrawer.widget.opennedButton,
                ),
              ),
            ],
          );
        } else if (cornerDrawer.drawerAnimation.isDismissed) {
          child = cornerDrawer.widget.closedButton;
        } else /* if (cornerDrawer.drawerAnimation.isCompleted) */ {
          child = cornerDrawer.widget.opennedButton;
        }

        return SizedBox(
          width: cornerDrawer.drawerAnimation.isDismissed ? cornerDrawer.widget.buttonSize.width : cornerDrawer._drawerWidth,
          height: cornerDrawer.drawerAnimation.isDismissed ? cornerDrawer.widget.buttonSize.height : MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: cornerDrawer.drawerAnimation.value * (cornerDrawer.widget.drawerWidth - cornerDrawer.widget.buttonSize.width) +
                      cornerDrawer.widget.buttonSize.width,
                  height:
                      cornerDrawer.drawerAnimation.value * (MediaQuery.of(context).size.height - cornerDrawer.widget.buttonSize.height) +
                          cornerDrawer.widget.buttonSize.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(cornerDrawer.widget.buttonRadius -
                            math.pow(cornerDrawer.drawerAnimation.value, 2) * cornerDrawer.widget.buttonRadius),
                      ),
                      boxShadow: buttonDecorationShadows,
                      gradient: buttonDecorationGradient,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: HeavyTouchButton(
                        onPressed: () => cornerDrawer.drawerAnimation.isCompleted ? cornerDrawer.closeDrawer() : cornerDrawer.openDrawer(),
                        child: SizedBox(
                          width: cornerDrawer.drawerAnimation.value *
                                  (cornerDrawer.widget.drawerWidth - cornerDrawer.widget.buttonSize.width) +
                              cornerDrawer.widget.buttonSize.width,
                          height: cornerDrawer.widget.buttonSize.height,
                          child: ColoredBox(
                            // Transparent ColoredBox is used to make the button work around the text
                            color: Colors.transparent,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ch,
            ],
          ),
        );
      },
      child: AnimatedBuilder(
        animation: cornerDrawer.extendedChildAniamtion,
        builder: (context, child) =>
            cornerDrawer.widget.extendedChildTransitionBuilder?.call(context, cornerDrawer.extendedChildAniamtion, child) ??
            _defaultExtendedChildTransitionBuilder(context, cornerDrawer.extendedChildAniamtion, child),
        child: cornerDrawer.drawerAnimation.isCompleted
            ? SizedBox(
                key: ValueKey(true),
              )
            : KeyedSubtree(
                child: cornerDrawer.widget.expandedChild,
                key: ValueKey(false),
              ),
      ),
    );
  }

  Widget _defaultExtendedChildTransitionBuilder(BuildContext context, Animation<double> animation, Widget child) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.5),
          end: Offset(0, 0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
}

class TabsCornerDrawer extends StatefulWidget {
  final Duration animationDuration;

  /// List of the screens(tabs) this drawer switches among
  final List<Widget> screens;

  /// Buttons responsible for switching to corresponding screens
  final List<Widget> tabButtons;

  /// Pointer widget that flies to the selected tab
  final Widget pointer;

  /// The child of the button that closes the drawer
  final Widget opennedButton;

  /// The child of the button that opens the drawer
  final Widget closedButton;
  final double drawerWidth;
  final Color color;
  final Color backgroundColor;
  final BorderRadius screenBorderRadius;
  final Duration drawerAnimationDuration;
  final double buttonRadius;
  final Duration extendedChildAnimationDuration;

  /// Size of the button in the closed position
  final Size buttonSize;

  /// Elevation of the screen
  final double elevation;

  /// How much should the screeen be covered in black when the drawer is open: 0.0 = no fade, 1.0 = fully black(not recommended)
  final double fadeAmount;

  /// How much should the screen scale down: 0.0 = no scale down, 1.0 = disappear
  final double scaleDownAmount;

  /// How much should the drawer overlap previous screen: 0.0 = no overlap, 1.0 = fully cover.
  /// Specify a negative nubmer to leave some space between the screen and the drawer
  final double overlap;

  Duration get fullAniamtionDuration => drawerAnimationDuration + extendedChildAnimationDuration;

  TabsCornerDrawer({
    @required this.pointer,
    @required this.opennedButton,
    @required this.closedButton,
    @required this.tabButtons,
    this.screens,
    this.animationDuration = const Duration(milliseconds: 135),
    this.drawerWidth,
    this.overlap = 0.0,
    this.scaleDownAmount = 0.1,
    this.color,
    this.backgroundColor,
    this.elevation = 3,
    this.fadeAmount = 0.6,
    this.screenBorderRadius,
    this.drawerAnimationDuration = const Duration(milliseconds: 300),
    this.buttonSize = const Size(60, 80),
    this.buttonRadius = 12,
    this.extendedChildAnimationDuration = const Duration(milliseconds: 100),
  });

  @override
  _TabsCornerDrawerState createState() => _TabsCornerDrawerState();
}

class _TabsCornerDrawerState extends State<TabsCornerDrawer> with TickerProviderStateMixin {
  int _currentIndex;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    assert(value >= 0 && value < widget.screens.length);
    _up = value > _currentIndex;
    _currentIndex = value;
    _controller.animateTo(_currentIndex.toDouble());
  }

  bool _up;

  AnimationController _controller;
  Animation<double> get controller => _controller.view;

  Widget get currentScreen => widget.screens[_currentIndex];

  @override
  void initState() {
    _controller = AnimationController(
      // lowerBound: 0.0,
      // upperBound: widget.screens.length - 1.0,
      duration: widget.animationDuration,
      vsync: this,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CornerDrawer(
      expandedChild: Builder(
        builder: (context) {
          return SafeArea(
            child: _DrawerTabBar(
              pointerPositionController: null, // TODO
              transitionAnimation: context.findAncestorStateOfType<_CornerDrawerState>().extendedChildAniamtion,
              pointer: Icon(Icons.arrow_right),
              tabs: [
                Text("Test tab"),
              ],
            ),
          );
        }
      ),
      opennedButton: widget.opennedButton,
      closedButton: widget.closedButton,
      screen: AnimatedSwitcher(
        duration: widget.animationDuration,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(
                0,
                _up
                    ? (_currentIndex == (child.key as ValueKey).value ? 0.7 : -0.7)
                    : (_currentIndex == (child.key as ValueKey).value ? -0.7 : 0.7),
              ),
              end: Offset(
                0,
                0,
              ),
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: currentScreen,
        ),
      ),
    );
  }
}

class _DrawerTabBar extends MultiChildRenderObjectWidget {
  final Widget pointer;
  final List<Widget> tabs;
  final Animation<double> pointerPositionController;
  final Animation<double> transitionAnimation;

  _DrawerTabBar({
    this.pointerPositionController,
    this.transitionAnimation,
    this.pointer,
    this.tabs,
  }) : super(children: [
          pointer,
          ...tabs,
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDrawerTabBar(
      pointerPositionController: null,
      transitionAnimation: null,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    // TODO: implement updateRenderObject
    super.updateRenderObject(context, renderObject);
  }
}

class _RenderDrawerTabBar extends RenderBox with ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  Animation<double> pointerPositionController;
  Animation<double> transitionAnimation;

  _RenderDrawerTabBar({
    @required this.pointerPositionController,
    @required this.transitionAnimation,
  });

  RenderBox get pointer => firstChild;

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {}
}
