import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class ItemTag {
  final String title;
  final Color color;

  ItemTag({
    this.title,
    this.color,
  });
}
