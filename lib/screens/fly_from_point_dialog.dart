import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:path/path.dart';

class FlyFromPointDialog extends TransitionRoute with TickerProviderMixin {
  final Offset sourcePosition;
  final Widget child;

  FlyFromPointDialog({
    this.sourcePosition,
    this.child,
  });

  RenderBox renderBox;

  @override
  void install() {
    super.install();
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: controller.value * 3, sigmaY: controller.value * 3),
          child: ColoredBox(
            color: Colors.black.withOpacity(controller.value * 0.5),
            child: child,
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
    yield OverlayEntry(
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints.loose(MediaQuery.of(context).size),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            renderBox ??= context.findRenderObject() as RenderBox;
            var offset = renderBox == null
                ? Offset.zero
                : (sourcePosition - Offset(renderBox.constraints.biggest.width, renderBox.constraints.biggest.height) * 0.5) * (1.0 - controller.value);

            return Transform.translate(
              offset: offset,
              child: child,
            );
          },
          child: ScaleTransition(
            scale: controller,
            child: Align(
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}
