import 'package:flutter/foundation.dart';
import 'package:grocery_list/models/grocery_item.dart';

import 'item_tag.dart';

class GroceryPrototype {
  final String id;
  final String title;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final int quantizationFractionDigits;
  final String currency;
  final double price;

  GroceryPrototype({
    String id,
    this.title = "",
    this.tags,
    this.unit = "it.",
    this.quantization = 1,
    this.quantizationFractionDigits = 0,
    this.currency = "\$",
    this.price = 0,
  }) : this.id = id ?? DateTime.now().toString();

  Map<String, Object> toJson() {
    return {
      "id": id,
      "title": title,
      "tags": "", // TODO: TAGS
      "unit": unit,
      "quantization": quantization,
      "currency": currency,
      "price": price,
      "fractionDigits": quantizationFractionDigits,
    };
  }

  static GroceryPrototype fromJson(Map<String, dynamic> json) {
    return GroceryPrototype(
      id: json["id"],
      currency: json["currency"],
      price: json["price"],
      quantization: json["quantization"],
      quantizationFractionDigits: json["fractionDigits"],
      tags: <ItemTag>[], // TODO: TAGS
      title: json["title"],
      unit: json["unit"],
    );
  }

  GroceryPrototype copyWith({
    String id,
    String title,
    List<ItemTag> tags,
    String unit,
    double quantization,
    int quantizationDecimalNumbersAmount,
    String currency,
    double price,
  }) {
    return GroceryPrototype(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      quantizationFractionDigits: quantizationDecimalNumbersAmount ?? this.quantizationFractionDigits,
      price: price ?? this.price,
      quantization: quantization ?? this.quantization,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      unit: unit ?? this.unit,
    );
  }

  ProductfulGroceryItem createGroceryItem() {
    return ProductfulGroceryItem(
      id: DateTime.now().toString(),
      amount: quantization,
      boundPrototype: this,
    );
  }

  bool equals(GroceryPrototype other) {
    return title == other.title && tags == other.tags && price == other.price && currency == other.currency && unit == other.unit;
  }
}
