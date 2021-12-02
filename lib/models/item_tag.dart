import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class ItemTag extends Equatable {
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

  @override
  List<Object> get props => [id];
}
