import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';

typedef OnChangeCallback = void Function(double value);

class GroceryItemAmount extends StatefulWidget {
  final double quantize;
  final int fractionDigits;
  final double value;
  final String unit;
  final bool expanded;
  final OnChangeCallback onChanged;

  GroceryItemAmount({
    this.quantize = 1,
    this.fractionDigits = 0,
    this.value = 0,
    this.unit,
    this.expanded = false,
    this.onChanged,
  });

  @override
  _GroceryItemAmount createState() => _GroceryItemAmount();
}

class _GroceryItemAmount extends State<GroceryItemAmount> {
  double _value;
  double get value => _value;
  set value(double value) {
    if (value == _value) return;

    setState(() {
      _up = value > _value;
      _value = value;
    });
  }

  bool _up = false;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GroceryItemAmount oldWidget) {
    if (widget.value != _value) {
      value = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  void increment() {
    setState(() {
      _up = true;
      _value += widget.quantize;
    });

    widget.onChanged(_value);
  }

  void decrement() {
    if (_value <= 0) return;

    setState(() {
      _up = false;
      _value -= widget.quantize;
    });

    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: widget.expanded
              ? HeavyTouchButton(
                  onPressed: decrement,
                  animationDuration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.remove_rounded,
                  ),
                )
              : SizedBox.shrink(),
        ),
        SizedBox(
          width: 45,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, _up ? (_value == (child.key as ValueKey).value ? 0.7 : -0.7) : (_value == (child.key as ValueKey).value ? -0.7 : 0.7)),
                              end: Offset(0, 0))
                          .animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _value.toStringAsFixed(widget.fractionDigits) + (widget.unit == null ? "" : " " + widget.unit),
                  key: ValueKey(_value),
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          alignment: Alignment.centerRight,
          duration: Duration(milliseconds: 400),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: widget.expanded
                ? HeavyTouchButton(
                    onPressed: increment,
                    animationDuration: const Duration(milliseconds: 100),
                    child: Icon(
                      Icons.add_rounded,
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
