import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_list/utils/golden_ration_utils.dart' as gr;

class PopOnSwipeRight extends StatefulWidget {
  final Widget child;
  final bool animateTransitionOut;
  final double speed;

  const PopOnSwipeRight({
    Key key,
    this.child,
    this.animateTransitionOut = true,
    this.speed = 2,
  }) : super(key: key);

  @override
  PopOnSwipeRightState createState() => PopOnSwipeRightState();
}

class PopOnSwipeRightState extends State<PopOnSwipeRight> with SingleTickerProviderStateMixin {
  AnimationController _poppingSwipeController;

  bool get hasPoppedOnSwipe => _poppingSwipeController.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    _poppingSwipeController = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _poppingSwipeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _poppingSwipeController.value = max(_poppingSwipeController.value + details.delta.dx, 0.0);
      },
      onHorizontalDragEnd: (details) {
        if (_poppingSwipeController.value * (details.velocity.pixelsPerSecond.dx + 1) / screenWidth / screenWidth > gr.invphi * gr.invphi) {
          if (widget.animateTransitionOut) {
            _poppingSwipeController
                .animateTo(screenWidth * 1.1, duration: Duration(milliseconds: ((screenWidth - _poppingSwipeController.value) / widget.speed).toInt()))
                .then((_) => Navigator.of(context).pop()); // 1.1 is here just in case the screen width is not enough
          } else {
            Navigator.of(context).pop();
          }
        } else {
          _poppingSwipeController.animateBack(0, duration: Duration(milliseconds: (_poppingSwipeController.value / widget.speed).toInt()));
        }
      },
      child: SlideTransition(
        position: Tween(begin: Offset(0, 0), end: Offset(1 / screenWidth, 0)).animate(_poppingSwipeController),
        child: widget.child,
      ),
    );
  }
}

mixin PopOnSwipeRightRouteMixin on TransitionRoute {
  @override
  Duration get reverseTransitionDuration => popOnSwipeRight.currentState != null && popOnSwipeRight.currentState.hasPoppedOnSwipe ? Duration.zero : transitionDuration;

  GlobalKey<PopOnSwipeRightState> popOnSwipeRight;

  @override
  void install() {
    popOnSwipeRight = GlobalKey<PopOnSwipeRightState>();

    super.install();
  }
}

@Deprecated(
    "Its midnight so im tired enough not to look up on google how to refer to a method implementation in the class the mixin is applied directly on") // TODO: PopOnSwipeRightWrapperRouteMixin
mixin PopOnSwipeRightWrapperRouteMixin on ModalRoute {
  @override
  Duration get reverseTransitionDuration => popOnSwipeRightState.currentState.hasPoppedOnSwipe ? Duration.zero : transitionDuration;

  GlobalKey<PopOnSwipeRightState> popOnSwipeRightState;

  @override
  void install() {
    popOnSwipeRightState = GlobalKey<PopOnSwipeRightState>();

    super.install();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return PopOnSwipeRight(
      key: popOnSwipeRightState,
      child: (this as ModalRoute).buildPage(context, animation, secondaryAnimation),
    );
  }
}
