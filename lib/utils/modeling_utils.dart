import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_utilities/color_utils.dart';

int findNextUnusedNumberForName(String newName, List<String> existingNames) {
  var matchingStartsWith = newName + " ";
  var existingNumbers = existingNames.map((e) {
    return int.tryParse(e.replaceFirst(matchingStartsWith, "")) ?? -1;
  }).toList()
    ..removeWhere((e) => e == -1);

  existingNumbers = existingNumbers.toSet().toList();
  existingNumbers.sort();

  if (existingNumbers.isEmpty || existingNumbers[0] != 1) return 1;

  for (var i = 1; i < existingNumbers.length; i++) {
    if (existingNumbers[i] != existingNumbers[i - 1] + 1) {
      return existingNumbers[i - 1] + 1;
    }
  }

  return existingNumbers.length + 1;
}

List<Color> getShadesOfMaterialColors(List<MaterialColor> colors, Set<int> shades) {
  List<Color> ret = [];

  for (var i in colors) {
    for (var j in shades) {
      try {
        ret.add(i[j]);
      } catch (e) {}
    }
  }

  return ret;
}

T modularDistance<T extends num>(T a, T b, T mod) => min((mod - a + b).abs(), (a - b).abs());

Color findTheMostDifferentColorTo(Color color, Set<Color> otherColors) => otherColors.reduce(
    (v, e) => v = (color.red + color.green + color.blue - e.red + e.green + e.blue).abs() > ((color.red + color.green + color.blue) - (v.red + v.green + v.blue)).abs() ? e : v);

List<double> rgbToCiexyz(Color color) {
  var var_R = (color.red as double) / 255.0;
  var var_G = (color.green as double) / 255.0;
  var var_B = (color.blue as double) / 255.0;

  if (var_R > 0.04045) {
    var_R = pow((var_R + 0.055) / 1.055, 2.4);
  } else {
    var_R = var_R / 12.92;
  }
  if (var_G > 0.04045) {
    var_G = pow((var_G + 0.055) / 1.055, 2.4);
  } else {
    var_G = var_G / 12.92;
  }
  if (var_B > 0.04045) {
    var_B = pow((var_B + 0.055) / 1.055, 2.4);
  } else {
    var_B = var_B / 12.92;
  }

  var_R = var_R * 100;
  var_G = var_G * 100;
  var_B = var_B * 100;

  var X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
  var Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
  var Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;

  return [X, Y, Z];
}

List<double> ciexyzToCieluv(List<double> color) {
  var X = color[0];
  var Y = color[1];
  var Z = color[2];

  var var_U = (4 * X) / (X + (15 * Y) + (3 * Z));
  var var_V = (9 * Y) / (X + (15 * Y) + (3 * Z));

  var var_Y = Y / 100;
  if (var_Y > 0.008856) {
    var_Y = pow(var_Y, 1.0 / 3.0);
  } else {
    var_Y = (7.787 * var_Y) + (16 / 116);
  }

  var ref_U = (4 * 111.144) / (111.144 + (15 * 100.000) + (3 * 35.200));
  var ref_V = (9 * 100.000) / (111.144 + (15 * 100.000) + (3 * 35.200));

  var CIE_L = (116 * var_Y) - 16;
  var CIE_u = 13 * CIE_L * (var_U - ref_U);
  var CIE_v = 13 * CIE_L * (var_V - ref_V);

  return [CIE_L, CIE_u, CIE_v];
}

Color findTheMostDifferentColorToSet(Set<Color> source, Set<Color> colors) {
  for (var rgbi in source) {
    double dif = 1;
    var i = HSVColor.fromColor(rgbi);

    for (var rgbj in colors) {
      var j = HSVColor.fromColor(rgbj);
      dif = modularDistance(i.hue / 360.0, j.hue / 360.0, 1.0) * i.value * j.value * i.saturation * i.value * 4.0 + (i.saturation - j.saturation).abs() + (i.value - j.value).abs();
    }
  }
}
