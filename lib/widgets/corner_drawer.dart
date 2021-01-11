import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:provider/provider.dart';
import '../utils/golden_ration_utils.dart' as gr;
import 'package:my_utilities/color_utils.dart';
import 'package:my_utilities/math_utils.dart' as math;
import 'package:vector_math/vector_math_64.dart' as vec;

typedef ButtonBuilder = Widget Function(BuildContext context, VoidCallback onPressed);
typedef WidgetWrapper = Widget Function(BuildContext context, Widget child);

class CornerDrawer extends StatefulWidget {
  final double drawerWidth;
  final Widget screen;
  final Widget expandedChild;
  final ButtonBuilder opennedButton;
  final ButtonBuilder closedButton;
  final Color color;
  final Color backgroundColor;
  final BorderRadius screenBorderRadius;
  final Duration drawerAnimationDuration;
  final double buttonRadius;
  final Duration extendedChildAnimationDuration;
  final AnimatedTransitionBuilder extendedChildTransitionBuilder;
  final AnimatedTransitionBuilder screenTransitionBuilder;

  /// Size of the butotn in the closed position
  final Size buttonSize;

  /// Elevation of the screen
  final double elevation;

  /// How much should the screeen be covered in black when the drawer is open: 0.0 = no fade, 1.0 = fully black(not recommended)
  final double fadeAmount;

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
    this.color,
    this.backgroundColor,
    this.elevation = 3,
    this.fadeAmount = 0.6,
    this.screenBorderRadius,
    this.drawerAnimationDuration = const Duration(milliseconds: 300),
    this.buttonSize = const Size(60, 80),
    this.buttonRadius = 12,
    this.extendedChildAnimationDuration = const Duration(milliseconds: 110),
    this.extendedChildTransitionBuilder,
    this.screenTransitionBuilder,
    Key key,
  }) : super(key: key);

  // Widget _defaultExtendedChildTransitionBuilder(BuildContext context, Animation<double> animation, Widget child) => child;

  @override
  _CornerDrawerState createState() => _CornerDrawerState();

  static _CornerDrawerState of(BuildContext context) => context.findAncestorStateOfType<_CornerDrawerState>();
}

class _CornerDrawerState extends State<CornerDrawer> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _slideAniamtion;
  Widget _screenTranstion;

  /// Animation representing opening and closing of the drawer
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

  double get animationsBorderValue => widget.drawerAnimationDuration.inMilliseconds / widget.fullAniamtionDuration.inMilliseconds;

  double get _drawerWidth => widget.drawerWidth ?? MediaQuery.of(context).size.width * (1 - gr.invphi * gr.invphi);

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.fullAniamtionDuration);
    // ..addStatusListener((status) {
    //   print(status);
    // });

    drawerAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, animationsBorderValue),
    );
    extendedChildAniamtion = CurvedAnimation(
      parent: _controller,
      curve: Interval(animationsBorderValue, 1.0),
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _slideAniamtion = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-_drawerWidth * (1.0 - widget.overlap) / MediaQuery.of(context).size.width, 0),
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
    var wrappedScreen = DecoratedBoxTransition(
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
    );

    return Stack(
      children: [
        ColoredBox(
          color: Theme.of(context).backgroundColor,
          child: SizedBox.expand(),
        ),
        SlideTransition(
          position: _slideAniamtion,
          child: widget.screenTransitionBuilder?.call(context, drawerAnimation, wrappedScreen) ??
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 0.8).animate(drawerAnimation),
                child: wrappedScreen,
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

    var openedButton = cornerDrawer.widget.opennedButton(context, () => cornerDrawer.closeDrawer());
    var closedButton = cornerDrawer.widget.closedButton(context, () => cornerDrawer.openDrawer());

    return AnimatedBuilder(
      animation: cornerDrawer.drawerAnimation,
      builder: (context, ch) {
        Widget child;

        if (cornerDrawer.drawerAnimation.status == AnimationStatus.forward) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Opacity(
                  opacity: 1.0 - cornerDrawer.drawerAnimation.value,
                  child: closedButton,
                ),
              ),
              Opacity(
                opacity: cornerDrawer.drawerAnimation.value,
                child: openedButton,
              ),
            ],
          );
        } else if (cornerDrawer.drawerAnimation.status == AnimationStatus.reverse) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1.0 - cornerDrawer.drawerAnimation.value,
                child: closedButton,
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: cornerDrawer.drawerAnimation.value,
                  child: openedButton,
                ),
              ),
            ],
          );
        } else if (cornerDrawer.drawerAnimation.isDismissed) {
          child = closedButton;
        } else /* if (cornerDrawer.drawerAnimation.isCompleted) */ {
          child = openedButton;
        }

        return SizedBox(
          width: cornerDrawer.drawerAnimation.isDismissed ? cornerDrawer.widget.buttonSize.width : cornerDrawer._drawerWidth,
          height: cornerDrawer.drawerAnimation.isDismissed ? cornerDrawer.widget.buttonSize.height : MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: cornerDrawer.drawerAnimation.value * (cornerDrawer._drawerWidth - cornerDrawer.widget.buttonSize.width) +
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
                          width: cornerDrawer.drawerAnimation.value * (cornerDrawer._drawerWidth - cornerDrawer.widget.buttonSize.width) +
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
              if (cornerDrawer.drawerAnimation.value >= 0.99) ch,
            ],
          ),
        );
      },
      child: AnimatedBuilder(
        animation: cornerDrawer.extendedChildAniamtion,
        builder: (context, child) =>
            cornerDrawer.widget.extendedChildTransitionBuilder?.call(context, cornerDrawer.extendedChildAniamtion, child) ??
            _defaultExtendedChildTransitionBuilder(context, cornerDrawer.extendedChildAniamtion, child),
        child: cornerDrawer.widget.expandedChild,
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
  final ButtonBuilder openedButton;

  /// The child of the button that opens the drawer
  final ButtonBuilder closedButton;
  final double drawerWidth;
  final Color color;
  final Color backgroundColor;
  final BorderRadius screenBorderRadius;
  final Duration drawerAnimationDuration;
  final double buttonRadius;
  final Duration extendedChildAnimationDuration;
  final AnimatedTransitionBuilder screenTransitionBuilder;
  final WidgetWrapper tabBarWrapper;

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
    @required this.openedButton,
    @required this.closedButton,
    @required this.tabButtons,
    @required this.screens,
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
    this.extendedChildAnimationDuration = const Duration(milliseconds: 240),
    this.screenTransitionBuilder,
    this.tabBarWrapper,
  });

  @override
  TabsCornerDrawerState createState() => TabsCornerDrawerState();
}

class TabsCornerDrawerState extends State<TabsCornerDrawer> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    assert(value >= 0 && value < widget.screens.length);
    setState(() {
      _up = value > _currentIndex;
      _currentIndex = value;
    });
    // _controller.animateTo(_currentIndex.toDouble());
  }

  bool _up = false;

  // AnimationController _controller;
  // Animation<double> get controller => _controller.view;

  Widget get currentScreen => widget.screens[_currentIndex];

  @override
  void initState() {
    // _controller = AnimationController(
    //   // lowerBound: 0.0,
    //   // upperBound: widget.screens.length - 1.0,
    //   duration: widget.animationDuration,
    //   vsync: this,
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tb = DrawerTabBar(
      vsync: this,
      selectedIndex: _currentIndex, // TODO
      pointer: widget.pointer,
      tabs: widget.tabButtons,
    );

    return CornerDrawer(
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      buttonRadius: widget.buttonRadius,
      buttonSize: widget.buttonSize,
      drawerAnimationDuration: widget.drawerAnimationDuration,
      drawerWidth: widget.drawerWidth,
      elevation: widget.elevation,
      extendedChildAnimationDuration: widget.extendedChildAnimationDuration,
      fadeAmount: widget.fadeAmount,
      overlap: widget.overlap,
      screenBorderRadius: widget.screenBorderRadius,
      screenTransitionBuilder: widget.screenTransitionBuilder,
      extendedChildTransitionBuilder: (context, animation, child) => child,
      expandedChild: SafeArea(
        child: widget.tabBarWrapper?.call(context, tb) ??
            Center(
              child: tb,
            ),
      ),
      opennedButton: widget.openedButton,
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

class DrawerTabBar extends MultiChildRenderObjectWidget {
  final Widget pointer;
  final List<Widget> tabs;

  final int selectedIndex;
  final Animation<double> transitionAnimation;
  final TickerProvider vsync;
  final double pointerIndentation;

  /// Duration of the pointer movement(idk how it relates to the velocity, I just passed it to the animation controller responsible for the pointer movement)
  final Duration duration;

  DrawerTabBar({
    this.pointerIndentation,
    this.duration,
    this.vsync,
    this.selectedIndex = 0,
    this.transitionAnimation,
    this.pointer,
    this.tabs,
  }) : super(children: [
          pointer,
          ...tabs,
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDrawerTabBar(
        selectedIndex, transitionAnimation ?? context.findAncestorStateOfType<_CornerDrawerState>()?.extendedChildAniamtion, vsync, pointerIndentation ?? 0,
        duration: duration);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderDrawerTabBar renderObject) {
    renderObject
      .._vsync = vsync
      ..transitionAnimation = transitionAnimation ?? context.findAncestorStateOfType<_CornerDrawerState>()?.extendedChildAniamtion
      ..selectedIndex = selectedIndex
      ..pointerIndentation = pointerIndentation ?? 0;
  }
}

class RenderDrawerTabBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  AnimationController _pointerPositionController;
  TickerProvider _vsync;
  List<double> _indexToOffset = [];
  List<double> get indexToOffset => List.unmodifiable(_indexToOffset);

  double _pointerIndentation;
  double get pointerIndentation => _pointerIndentation;
  set pointerIndentation(double value)
  {
    if (_pointerIndentation == value) return;

    _pointerIndentation = value;

    markNeedsLayout();
  }

  int _selectedIndex;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    if (value == _selectedIndex) return;

    _selectedIndex = value;
    _pointerPositionController.animateTo(_indexToOffset[value]);
  }

  Animation<double> _transitionAnimation;
  Animation<double> get transitionAnimation => _transitionAnimation;
  set transitionAnimation(Animation<double> value) {
    if (identical(value, _transitionAnimation)) return;

    value.addListener(_handleTransitionAnimation);
    _transitionAnimation.removeListener(_handleTransitionAnimation);
    _transitionAnimation = value;
  }

  set duration(Duration value) {
    if (value == _pointerPositionController.duration) return;
    _pointerPositionController.duration = value;
  }

  RenderDrawerTabBar(
    this._selectedIndex,
    this._transitionAnimation,
    this._vsync,
    this._pointerIndentation, {
    Duration duration,
  }) : _pointerPositionController = AnimationController.unbounded(duration: duration ?? Duration(milliseconds: 100), vsync: _vsync);

  RenderBox get pointer => firstChild;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = MultiChildLayoutParentData();
  }

  @override
  void attach(covariant PipelineOwner owner) {
    // It's unbounded so it is not required to be recreated on every relayout when the height changes
    _pointerPositionController.addListener(_handlePointerPositionAnimation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transitionAnimation.addListener(_handleTransitionAnimation);
    });

    super.attach(owner);
  }

  @override
  void detach() {
    _pointerPositionController.removeListener(_handlePointerPositionAnimation);
    _transitionAnimation.removeListener(_handleTransitionAnimation);
    _pointerPositionController.dispose();
    super.detach();
  }

  void _handleTransitionAnimation() {
    markNeedsPaint();
  }

  void _handlePointerPositionAnimation() {
    markNeedsPaint();
  }

  @override
  void performLayout() {
    // TODO: Make its Column capabilities be more configurable(main/cross axis alignment and so on)
    RenderBox current = childAfter(pointer);
    double spaceLeft = constraints.maxHeight;

    _indexToOffset = List<double>.filled(childCount - 1, 0);

    pointer.layout(
        BoxConstraints(
          minWidth: 0,
          maxWidth: constraints.maxWidth * gr.invphi,
          minHeight: 0,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true);

    for (int i = 0; i < childCount - 1; i++) {
      current.layout(
        BoxConstraints(
          minWidth: math.max(constraints.minWidth - pointer.size.width - _pointerIndentation, 0),
          maxWidth: math.max(constraints.maxWidth - pointer.size.width - _pointerIndentation, 0),
          minHeight: 0,
          maxHeight: spaceLeft,
        ),
        parentUsesSize: true,
      );
      
      (current.parentData as ContainerBoxParentData).offset =
          Offset(pointer.size.width + _pointerIndentation, (i - 1 >= 0 ? _indexToOffset[i - 1] : 0) + childBefore(current)?.size?.height ?? 0 / 2);

      spaceLeft = spaceLeft - current.size.height;

      _indexToOffset[i] = (current.parentData as ContainerBoxParentData).offset.dy + current.size.height / 2 - pointer.size.height / 2;

      current = childAfter(current);
    }

    size = Size(constraints.maxWidth, (lastChild.parentData as ContainerBoxParentData).offset.dy + lastChild.size.height);
    // This size computation is not accurate, the pointer may overflow the widget in case it's height is bigger than heigh of the first or the last children

    _pointerPositionController.value = _indexToOffset[_selectedIndex];
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox current = childAfter(pointer);
    var pointerValue = Curves.easeOutQuint.transform((transitionAnimation.value * 1.5 - 1.0 / 1.5).clamp(0.0, 1.0)).toDouble();

    context.pushOpacity(offset, (pointerValue * 255).round(), (context, offset) {
      context.paintChild(
          pointer, Offset(offset.dx, offset.dy + _pointerPositionController.value + (1.0 - pointerValue) * 0.8 * size.height));
    });

    for (int i = 0; i < childCount - 1; i++) {
      var buttonValue = _sequentiallyStartingAnimations(transitionAnimation.value, childCount - i - 2, childCount - 1, 0.3);

      context.pushOpacity(offset, (buttonValue * 255.0).toInt().clamp(0, 255), (context, offset) {
        context.paintChild(
            current, offset + (current.parentData as ContainerBoxParentData).offset + Offset(0, (1.0 - buttonValue) * size.height * 0.5));
      });

      current = childAfter(current);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  static double _sequentiallyStartingAnimations(double t, int index, int maxIndex, double shift) {
    var o = 1 / maxIndex + shift * (1 - 1 / maxIndex); // Lerp between inverse of [[maxIndex]] and 1 via shift
    return math.clip(o * maxIndex * t - (o * maxIndex - 1) * index / (maxIndex - 1), 0.0, 1.0);

    // return 1;
  }
}
