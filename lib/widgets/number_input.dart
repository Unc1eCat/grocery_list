import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';

typedef OnChange = void Function(double value);

class NumberInput extends StatefulWidget {
  final double quantize;
  final int fractionDigits;
  final double value;
  final TextStyle style;
  final ButtonBuilder minusButton;
  final ButtonBuilder plusButton;
  final double max;
  final double min;
  final String unit;
  final OnChange onChanged;
  final Duration longPressPeriod;

  NumberInput({
    this.minusButton,
    this.plusButton,
    this.quantize = 1,
    this.fractionDigits = 0,
    this.value = 0,
    this.style,
    this.max = double.maxFinite,
    this.min = 0.0,
    this.unit,
    this.onChanged,
    this.longPressPeriod,
  });

  @override
  _NumberInputState createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  StreamSubscription<void> _longPress;
  double _value;
  double get value => _value;
  set value(double value) {
    if (value == _value) return;

    widget?.onChanged?.call(value);

    setState(() {
      _up = value > _value;
      _value = value;
    });
  }

  bool _up = false;

  @override
  void initState() {
    _longPress = Stream<void>.periodic(widget.longPressPeriod ?? Duration(milliseconds: 160)).listen((_) => increment());
    _longPress.pause();
    _value = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NumberInput oldWidget) {
    if (widget.value != _value) {
      value = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  void increment() {
    if (_value >= widget.max) return;

    widget?.onChanged?.call(value + 1);

    setState(() {
      _up = true;
      _value++;
    });
  }

  void decrement() {
    if (_value <= widget.min) return;

    widget?.onChanged?.call(value - 1);

    setState(() {
      _up = false;
      _value--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.minusButton?.call(
              context,
              decrement,
              () => _longPress = _longPress
                ..onData((_) => decrement())
                ..resume(),
              () => _longPress.pause(),
            ) ??
            HeavyTouchButton(
              onPressed: decrement,
              onLongPress: () => _longPress = _longPress
                ..onData((_) => decrement())
                ..resume(),
              onUp: () => _longPress.pause(),
              pressedScale: 0.85,
              animationDuration: Duration(milliseconds: 100),
              child: Icon(
                Icons.remove,
                size: 30,
              ),
            ),
        SizedBox(width: 5),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(
                            0,
                            _up
                                ? (_value == (child.key as ValueKey).value ? 0.7 : -0.7)
                                : (_value == (child.key as ValueKey).value ? -0.7 : 0.7)),
                        end: Offset(0, 0))
                    .animate(animation),
                child: child,
              ),
            );
          },
          child: SizedBox(
            key: ValueKey(_value),
            width: 45,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Center(
                child: Text(
                  _value.toStringAsFixed(widget.fractionDigits) + (widget.unit == null ? "" : " " + widget.unit),
                  style: widget.style ?? Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
        ),
        widget.plusButton?.call(
              context,
              increment,
              () => _longPress = _longPress
                ..onData((_) => decrement())
                ..resume(),
              () => _longPress.pause(),
            ) ??
            HeavyTouchButton(
              onLongPress: () => _longPress = _longPress
                ..onData((_) => increment())
                ..resume(),
              onUp: () => _longPress.pause(),
              onPressed: increment,
              pressedScale: 0.85,
              animationDuration: Duration(milliseconds: 100),
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
      ],
    );
  }
}
