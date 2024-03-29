import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:grocery_list/utils/serealization_utils.dart';

@immutable
class ItemTag extends Equatable implements ToJson {
  final String id;
  final String title;
  final Color color;

  ItemTag({
    String id,
    this.title,
    this.color,
  }) : this.id = id ?? DateTime.now().toString();

  ItemTag copyWith({
    String id,
    String title,
    Color color,
  }) =>
      ItemTag(
        id: id ?? this.id,
        title: title ?? this.title,
        color: color ?? this.color,
      );

  ItemTag.fromJson(Map<String, Object> json)
      : id = json["id"],
        title = json["title"],
        color = Color(json["color"]);

  @override
  List<Object> get props => [id];

  @override
  Object toJson() => {
        "id": id,
        "title": title,
        "color": color.value,
      };
}
