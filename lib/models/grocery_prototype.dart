import 'package:flutter/foundation.dart';
import 'package:grocery_list/models/grocery_item.dart';

import 'item_tag.dart';

class GroceryPrototype {
  final String title;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final int quantizationDecimalNumbersAmount;
  final String currency;
  final double price;

  GroceryPrototype({
    this.title = "",
    this.tags,
    this.unit = "it.",
    this.quantization = 1,
    this.quantizationDecimalNumbersAmount = 0,
    this.currency = "\$",
    this.price = 0,
  });

  Map<String, Object> toJson() {
    return {
      "title": title,
      "tags": "", // TODO: TAGS
      "unit": unit,
      "quantization": quantization,
      "currency": currency,
      "price": price,
      "fractionDigits": quantizationDecimalNumbersAmount,
    };
  }

  static GroceryPrototype fromJson(Map<String, dynamic> json) {
    return GroceryPrototype(
      currency: json["currency"],
      price: json["price"],
      quantization: json["quantization"],
      quantizationDecimalNumbersAmount: json["fractionDigits"],
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
      currency: currency ?? this.currency,
      quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount ?? this.quantizationDecimalNumbersAmount,
      price: price ?? this.price,
      quantization: quantization ?? this.quantization,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      unit: unit ?? this.unit,
    );
  }

  GroceryItem createGroceryItem() {
    return GroceryItem(
      id: DateTime.now().toString(),
      amount: 1,
      currency: currency,
      price: price,
      quantization: quantization,
      quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount,
      tags: tags,
      title: title,
      unit: unit,
    );
  }

  bool equals(GroceryPrototype other) {
    return title == other.title && tags == other.tags && price == other.price && currency == other.currency && unit == other.unit;
  }
}
