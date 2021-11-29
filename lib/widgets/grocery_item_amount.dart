import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_list/bloc/grocery_list_bloc.dart';
import 'package:grocery_list/widgets/corner_drawer.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';

typedef OnChange = void Function(double value);

class GroceryItemAmount extends StatefulWidget {
  final double quantize;
  final int fractionDigits;
  final double value;
  final String unit;
  final bool expanded;
  final GroceryListBloc bloc;

  GroceryItemAmount({
    this.quantize = 1,
    this.fractionDigits = 0,
    this.value = 0,
    this.unit,
    this.expanded = false,
    this.bloc,
  });

  @override
  _GroceryItemAmount createState() => _GroceryItemAmount();
}

class _GroceryItemAmount extends State<GroceryItemAmount> {
  StreamSubscription<void> _longPress;
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
    _longPress = Stream<void>.periodic(const Duration(milliseconds: 240)).listen((_) => increment());
    _longPress.pause();
    _value = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
  }

  void decrement() {
    if (_value <= 0) return;

    setState(() {
      _up = false;
      _value -= widget.quantize;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = widget.bloc;

    return Row(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: widget.expanded
              ? HeavyTouchButton(
                  onPressed: decrement,
                  onLongPress: () => _longPress = _longPress
                    ..onData((_) => decrement())
                    ..resume(),
                  onUp: () => _longPress.pause(),
                  animationDuration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.remove,
                    size: 30,
                  ),
                )
              : SizedBox.shrink(),
        ),
        SizedBox(width: 5),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(0, _up ? (_value == (child.key as ValueKey).value ? 0.7 : -0.7) : (_value == (child.key as ValueKey).value ? -0.7 : 0.7)), end: Offset(0, 0))
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
                    onLongPress: () => _longPress = _longPress
                      ..onData((_) => increment())
                      ..resume(),
                    onUp: () => _longPress.pause(),
                    onPressed: increment,
                    animationDuration: const Duration(milliseconds: 100),
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
