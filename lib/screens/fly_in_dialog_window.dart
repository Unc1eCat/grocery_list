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
            var renderBox = context.findRenderObject() as RenderBox;
            var finalOffset = renderBox == null ? Offset.zero : (renderBox.constraints.biggest / 2 - renderBox.size / 2 as Offset);
            var offset = (sourcePosition - Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.5) * (1.0 - controller.value);
      
            print((finalOffset - sourcePosition) * controller.value + sourcePosition);
      
            return Transform.translate(
              // offset: Offset(offset.width, offset.height),
              
              offset: offset,
              child: child,
            );
          },
          child: ScaleTransition(
            scale: controller,
            child: child,
          ),
        ),
      ),
    );

    // yield OverlayEntry(
    //   builder: (context) => _FlyFromPointDialogInternal(
    //     child: child,
    //     controller: controller,
    //     sourceOffset: sourcePosition,
    //   ),
    // );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 3000);
}

// class _FlyFromPointDialogInternal extends SingleChildRenderObjectWidget {
//   final Widget child;
//   final Offset sourceOffset;
//   final AnimationController controller;

//   _FlyFromPointDialogInternal({
//     this.controller,
//     this.child,
//     this.sourceOffset,
//   }) : super(child: child);

//   @override
//   RenderObject createRenderObject(BuildContext context) => _RenderFlyFromPointDialogInternal(
//         sourceOffset: sourceOffset,
//         controller: controller,
//       );

//   @override
//   void updateRenderObject(BuildContext context, _RenderFlyFromPointDialogInternal renderObject) {
//     renderObject
//       ..sourceOffset = sourceOffset
//       ..controller = controller;
//   }
// }

// class _RenderFlyFromPointDialogInternal extends RenderShiftedBox with TickerProviderMixin {
//   _RenderFlyFromPointDialogInternal({Offset sourceOffset, RenderBox child, AnimationController controller})
//       : this._sourceOffset = sourceOffset,
//         super(child) {
//     this.controller = controller..addListener(markNeedsPaint);
//   }

//   Offset _sourceOffset;
//   Offset get sourceOffset => Offset(_sourceOffset.dx, _sourceOffset.dy);
//   set sourceOffset(Offset val) {
//     if (val == _sourceOffset) return;
//     _sourceOffset = val;
//     markNeedsLayout();
//   }

//   AnimationController _controller;
//   AnimationController get controller => _controller;
//   set controller(AnimationController val) {
//     if (identical(val, _sourceOffset)) return;
//     _controller?.removeListener(markNeedsPaint);
//     _controller = val;
//     _controller.addListener(markNeedsPaint);
//   }

//   @override
//   void performLayout() {
//     child.layout(constraints.loosen(), parentUsesSize: true);

//     var childParentData = child.parentData as BoxParentData;

//     size = constraints.biggest;
//     childParentData.offset = size / 2 - child.size / 2;
//   }

//   @override
//   void paint(PaintingContext context, Offset offset) {
//     var childParentData = child.parentData as BoxParentData;
//     var childOffset = childParentData.offset + (sourceOffset - childParentData.offset) * _controller.value;

//     context.pushLayer(
//         BackdropFilterLayer(
//           blendMode: BlendMode.srcOver,
//           filter: ImageFilter.blur(
//             sigmaX: 3.0 * _controller.value,
//             sigmaY: 3.0 * _controller.value,
//           ),
//         ),
//         (context, offset) => context.canvas.drawRect(
//               Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
//               Paint()..color = Colors.black.withOpacity(0.5 * _controller.value),
//             ),
//         offset);

//     context.pushTransform(
//       needsCompositing,
//       Offset.zero,
//       Matrix4.identity()..translate(childOffset.dx, childOffset.dy),
//       (context, offset) => context.pushTransform(
//         needsCompositing,
//         Offset.zero,
//         Matrix4.translationValues(-child.size.width / 2, -child.size.height / 2, 0)
//           ..multiply(Matrix4(_controller.value, 0, 0, 0, 0, _controller.value, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1))
//           ..translate(child.size.width / 2, child.size.height / 2, 0),
//         (context, offset) => context.paintChild(child, Offset(0.0, 0.0)),
//       ),
//     );
//   }
// }
