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

Color findTheMostDifferentColorToSet(Set<Color> source, Set<Color> colors) {
  for (var rgbi in source) {
    int dif = 1;
    var i = HSVColor.fromColor(rgbi);

    for (var rgbj in colors) {
      var j = HSVColor.fromColor(rgbj);
      dif = modularDistance();
    }
  }
}
