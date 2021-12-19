import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';

class BlurryFadedBackground extends SingleChildRenderObjectWidget {
  final Widget child;
  final Offset sourceOffset;
  final Animation<double> controller;

  BlurryFadedBackground({
    this.controller,
    this.child,
    this.sourceOffset,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderBurryFadedBackground(
        controller: controller,
      );

  @override
  void updateRenderObject(BuildContext context, RenderBurryFadedBackground renderObject) {
    renderObject..controller = controller;
  }
}

class RenderBurryFadedBackground extends RenderShiftedBox with TickerProviderMixin {
  RenderBurryFadedBackground({RenderBox child, Animation<double> controller}) : super(child) {
    this.controller = controller..addListener(markNeedsPaint);
  }

  Animation<double> _controller;
  Animation<double> get controller => _controller;
  set controller(Animation<double> val) {
    if (identical(val, _controller)) return;
    _controller?.removeListener(markNeedsPaint);
    _controller = val;
    _controller.addListener(markNeedsPaint);
  }

  @override
  void performLayout() {
    child.layout(constraints.loosen(), parentUsesSize: true);

    var childParentData = child.parentData as BoxParentData;

    childParentData.offset = Offset.zero;
    size = constraints.biggest;
  }

  var darkPaint = Paint();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!(layer is BackdropFilterLayer)) {
      layer = BackdropFilterLayer(
        blendMode: BlendMode.srcOver,
        filter: ImageFilter.blur(
          sigmaX: 3.0 * _controller.value,
          sigmaY: 3.0 * _controller.value,
        ),
      );
    }

    (layer as BackdropFilterLayer).filter = ImageFilter.blur(
      sigmaX: 3.0 * _controller.value,
      sigmaY: 3.0 * _controller.value,
    );

    context.pushLayer(
      layer,
      (context, offset) => context.canvas.drawRect(
        offset & size,
        darkPaint..color = Colors.black.withOpacity(0.6 * _controller.value.clamp(0.0, 1.0)),
      ),
      offset,
      childPaintBounds: offset & size,
    );

    super.paint(context, offset);
  }
}
