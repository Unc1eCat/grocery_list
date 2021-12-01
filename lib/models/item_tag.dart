import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class ItemTag {
  final String id;
  final String title;
  final Color color;

  ItemTag({
    String id,
    this.title,
    this.color,
  }) : this.id = id ?? DateTime.now().toString();
}
