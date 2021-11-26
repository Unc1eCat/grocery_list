import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_list/utils/golden_ration_utils.dart' as gr;

class PopOnSwipeRight extends StatefulWidget {
  final Widget child;

  const PopOnSwipeRight({Key key, this.child}) : super(key: key);

  @override
  _PopOnSwipeRightState createState() => _PopOnSwipeRightState();
}

class _PopOnSwipeRightState extends State<PopOnSwipeRight> with SingleTickerProviderStateMixin {
  AnimationController _poppingSwipeController;

  @override
  void initState() {
    super.initState();
    _poppingSwipeController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
          _poppingSwipeController.animateTo(screenWidth * 1.1).then((_) => Navigator.of(context).pop()); // 1.1 is here just in case the screen width is not enough
        } else {
          _poppingSwipeController.animateTo(0);
        }
      },
      child: SlideTransition(
        position: Tween(begin: Offset(0, 0), end: Offset(1 / screenWidth, 0)).animate(_poppingSwipeController),
        child: widget.child,
      ),
    );
  }
}
