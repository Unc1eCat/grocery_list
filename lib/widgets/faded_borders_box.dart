import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FadedBordersBox extends StatelessWidget {
  static const _colorsOnlyFirst = const [Colors.transparent, Colors.white];
  static const _colorsBoth = const [Colors.transparent, Colors.white, Colors.white, Colors.transparent];

  /// How many percents of the child to fade from the left (0.0 - no fade, 1.0 - full fade)
  final double left;

  /// How many percents of the child to fade from the top (0.0 - no fade, 1.0 - full fade)
  final double top;

  /// How many percents of the child to fade from the right (0.0 - no fade, 1.0 - full fade)
  final double right;

  /// How many percents of the child to fade from the bottom (0.0 - no fade, 1.0 - full fade)
  final double bottom;

  /// The child fade will be applied to
  final Widget child;

  const FadedBordersBox({
    Key key,
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.child,
  })  : assert(0.0 <= top && top <= 1.0),
        assert(0.0 <= right && right <= 1.0),
        assert(0.0 <= bottom && bottom <= 1.0),
        assert(0.0 <= left && left <= 1.0),
        assert(top <= 1.0 - bottom),
        assert(left <= 1.0 - right),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget wrapWithFades(Widget child, List<Color> colors, Alignment begin, Alignment end, List<double> stops) {
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
          stops: stops,
        ).createShader(bounds),
        child: child,
      );
    }

    Widget ret = child;

    // Vertical fades
    if (top > 0 && bottom > 0) {
      ret = wrapWithFades(
        child,
        _colorsBoth,
        Alignment.topCenter,
        Alignment.bottomCenter,
        [0.0, top, 1.0 - bottom, 1.0],
      );
    } else if (top > 0) {
      ret = wrapWithFades(
        child,
        _colorsOnlyFirst,
        Alignment.topCenter,
        Alignment.bottomCenter,
        [0.0, top],
      );
    } else if (bottom > 0) {
      ret = wrapWithFades(
        child,
        _colorsOnlyFirst,
        Alignment.bottomCenter,
        Alignment.topCenter,
        [0.0, bottom],
      );
    }

    // Horizontal fades
    if (left > 0 && right > 0) {
      return wrapWithFades(
        ret,
        _colorsBoth,
        Alignment.centerLeft,
        Alignment.centerRight,
        [0.0, left, 1.0 - right, 1.0],
      );
    } else if (left > 0) {
      return wrapWithFades(
        ret,
        _colorsOnlyFirst,
        Alignment.centerLeft,
        Alignment.centerRight,
        [0.0, left],
      );
    } else if (right > 0) {
      return wrapWithFades(
        ret,
        _colorsOnlyFirst,
        Alignment.centerRight,
        Alignment.centerLeft,
        [0.0, right],
      );
    }
  }
}
