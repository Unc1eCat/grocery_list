import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/utils/ticker_provider_mixin.dart';
import 'package:grocery_list/widgets/blurry_faded_background.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/smart_text_field.dart';
import '../utils/golden_ration_utils.dart' as gr;

typedef OnPickedColorChangedCallback = void Function(Color pickedColor);

class ColorPickerDialog extends PageRoute<Color> with TickerProviderMixin {
  final List<Color> availableColors;
  final int colorsInARow;

  ColorPickerDialog({
    this.colorsInARow = 7,
    this.availableColors = const [],
    Color pickedColor,
    OnPickedColorChangedCallback onPickedColorChanged,
  }) : assert(availableColors.contains(pickedColor)) {
    _pickedColorController = ValueNotifier<Color>(pickedColor)..addListener(() => onPickedColorChanged(_pickedColorController.value));
  }

  AnimationController _animationController;
  ScrollController _scrollController;
  ValueNotifier<Color> _pickedColorController;

  @override
  void install() {
    _animationController = AnimationController(vsync: this)..animateTo(1.0, duration: const Duration(milliseconds: 500));
    _scrollController = ScrollController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    super.install();
  }

  @override
  void dispose() {
    disposeTickers();
    _pickedColorController.dispose();
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

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => "";

  @override
  Color get currentResult => _pickedColorController.value;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return BlurryFadedBackground(
      controller: _animationController,
      child: FadeTransition(
        opacity: _animationController,
        child: GridView.count(
          addRepaintBoundaries: true,
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          controller: _scrollController,
          padding: EdgeInsets.only(right: 30, left: 30, top: MediaQuery.of(context).padding.top + 100),
          crossAxisCount: colorsInARow,
          mainAxisSpacing: 15,
          crossAxisSpacing: 2,
          childAspectRatio: gr.phi,
          children: availableColors
              .map((e) => HeavyTouchButton(
                    onPressed: () {
                      _pickedColorController.value = e;
                    },
                    child: ColorOption(
                      color: e,
                      pickedColorController: _pickedColorController,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);
}

class ColorOption extends LeafRenderObjectWidget {
  final ValueNotifier<Color> pickedColorController;
  final Color color;

  const ColorOption({
    this.color,
    this.pickedColorController,
    Key key,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderColorOption(color: color, pickedColorController: pickedColorController);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderColorOption renderObject) {
    renderObject
      ..color = color
      ..pickedColorController = pickedColorController;
  }
}

class RenderColorOption extends RenderBox with TickerProviderMixin {
  RenderColorOption({ValueNotifier<Color> pickedColorController, Color color}) {
    _controller = AnimationController(value: pickedColorController.value == color ? 1.0 : 0.0, vsync: this, duration: Duration(milliseconds: 200))..addListener(markNeedsPaint);
    _color = color;
    _pickedColorController = pickedColorController;
    _pickedColorController.addListener(pickColor);
    _rectPaint = Paint()..color = color;
    _borderPaint = Paint()..color = Colors.white;
  }

  AnimationController _controller;
  Paint _rectPaint;
  Paint _borderPaint;

  ValueNotifier<Color> _pickedColorController;
  ValueNotifier<Color> get pickedColorController => _pickedColorController;
  set pickedColorController(ValueNotifier<Color> val) {
    if (identical(val, _pickedColorController)) return;
    _pickedColorController.removeListener(pickColor);
    _pickedColorController = val;
    _pickedColorController.addListener(pickColor);
    pickColor();
  }

  Color _color;
  Color get color => _color;
  set color(Color val) {
    if (val == _color) return;
    _color = val;
    _rectPaint.color = val;
    pickColor();
  }

  void pickColor() {
    var ticked = _pickedColorController.value == color;

    if (ticked == (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward)) return;
    if (ticked) {
      _controller.animateTo(1.0);
    } else {
      _controller.animateBack(0.0);
    }
  }

  @override
  void dispose() {
    disposeTickers();
    _controller.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    var v = _controller.value;
    var padding = v * 8 + (1 - v) * 5;
    var borderThickness = v * 4;

    context.canvas.drawRRect(
        RRect.fromLTRBR(offset.dx + padding, offset.dy + padding, offset.dx + size.width - padding, offset.dy + size.height - padding, const Radius.circular(12)), _rectPaint);
    if (v != 0.0)
      context.canvas.drawDRRect(
          RRect.fromLTRBR(offset.dx, offset.dy, offset.dx + size.width, offset.dy + size.height, const Radius.circular(16)),
          RRect.fromLTRBR(offset.dx + borderThickness, offset.dy + borderThickness, offset.dx + size.width - borderThickness, offset.dy + size.height - borderThickness,
              const Radius.circular(14)),
          _borderPaint);
  }
}
