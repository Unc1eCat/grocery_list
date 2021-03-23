import 'package:flutter/material.dart';

import 'heavy_touch_button.dart';
import 'package:my_utilities/color_utils.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final IconData icon;
  final String title;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const ActionButton({
    Key key,
    @required this.onPressed,
    @required this.color,
    @required this.icon,
    @required this.title,
    this.borderRadius,
    this.padding = const EdgeInsets.all(12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeavyTouchButton(
      pressedScale: 0.9,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(30),
          border: Border.all(
            width: 1.2,
            color: color.withRangedHsvSaturation(0.8),
          ),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 8,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
