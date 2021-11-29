import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import '../utils/golden_ration_utils.dart' as gr;

class GroceryItemTagSetting extends LeafRenderObjectWidget {
  final String title;
  final TextStyle style;
  final Color color;
  final bool ticked;
  final EdgeInsets padding;
  final Duration duration;

  GroceryItemTagSetting({
    Duration duration,
    this.ticked = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.title,
    this.style,
    this.color,
  }) : this.duration = duration ?? Duration(milliseconds: 200);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGroceryItemTagSetting()
      ..title = title
      ..color = color
      ..duration = duration
      ..ticked = ticked
      ..style = style
      ..padding = padding;
    ;
  }

  @override
  void updateRenderObject(BuildContext context, RenderGroceryItemTagSetting renderObject) => renderObject
    ..title = title
    ..color = color
    ..duration = duration
    ..ticked = ticked
    ..style = style
    ..padding = padding;
}

class RenderGroceryItemTagSetting extends RenderBox with TickerProviderMixin {
  static const Size badgeSize = const Size(20, 20 / gr.phi);
  static const double indent = 6;

  RenderGroceryItemTagSetting() {
    _controller = AnimationController(vsync: this);
    _textPainter = TextPainter(textDirection: TextDirection.ltr);
  }

  TextPainter _textPainter;
  BoxPainter _boxPainter;

  AnimationController _controller;
  // AnimationController get controller => _controller;
  // set controller(AnimationController val) {
  //   _controller = val;
  //   _controller.addListener(markNeedsPaint);

  //   markNeedsPaint();
  // }

  Duration get duration => _controller.duration;
  set duration(Duration val) {
    if (val == _controller.duration) return;
    _controller.duration = val;
  }

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets val) {
    if (val == _padding) return;
    _padding = val;
    markNeedsLayout();
    markNeedsPaint();
  }

  String _title;
  String get title => _title;
  set title(String val) {
    if (val == _title) return;
    _title = val;
    _textPainter.text = TextSpan(style: style, text: title);
    _textPainter.layout();
    markNeedsLayout();
    markNeedsPaint();
  }

  TextStyle _style;
  TextStyle get style => _style;
  set style(TextStyle val) {
    if (val == _style) return;
    _style = val;
    _textPainter.text = TextSpan(style: style, text: title);
    _textPainter.layout();
    markNeedsLayout();
    markNeedsPaint();
  }

  Color _color;
  Color get color => _color;
  set color(Color val) {
    if (val == _color) return;
    _color = val;
    _boxPainter = BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: color,
    ).createBoxPainter();
    markNeedsPaint();
  }

  bool _ticked;
  bool get ticked => _ticked;
  set ticked(bool val) {
    if (val == _ticked) return;
    _ticked = val;
    if (_ticked) {
      _controller.animateTo(1.0);
    } else {
      _controller.animateBack(0.0);
    }
    markNeedsPaint();
  }

  @override
  void dispose() {
    _controller.removeListener(markNeedsPaint);
    _controller.dispose();
    disposeTickers();

    super.dispose();
  }

  @override
  void performLayout() {
    size = Size(_padding.horizontal + badgeSize.width + indent + _textPainter.size.width, _padding.vertical + max(_textPainter.height, badgeSize.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var v = _controller.value; // Value
    var rv = 1 - v; // Reverse animation's Value

    _boxPainter.paint(context.canvas, offset + Offset(rv * _padding.left, rv * (_padding.top + (_textPainter.height - badgeSize.height) / 2)),
        ImageConfiguration(size: Size(badgeSize.width + v * (size.width - badgeSize.width), badgeSize.height + v * (size.height - badgeSize.height))));
    _textPainter.paint(context.canvas,
        offset + Offset((size.width - _textPainter.width) / 2 + rv * ((_padding.left + badgeSize.width + indent) - (size.width - _textPainter.width) / 2), _padding.top));

    super.paint(context, offset);
  }
}
