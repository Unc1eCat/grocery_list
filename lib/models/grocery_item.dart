import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/item_tag.dart';

@immutable
class GroceryItem {
  final String id;
  final String title;
  final bool checked;
  final List<ItemTag> tags;
  final String unit;
  final double quantization;
  final int quantizationDecimalNumbersAmount;
  final String currency;
  final double price;
  final double amount;

  GroceryItem({
    String id, 
    this.unit = "it.",
    this.quantization = 1.0,
    this.quantizationDecimalNumbersAmount = 0,
    this.currency = "₽",
    this.price = 0.0,
    this.amount = 0.0,
    this.title = "New item",
    this.checked = false,
    this.tags = const [
      // ItemTag(color: Colors.red, title: "Test red tag"),
      // ItemTag(color: Colors.blue, title: "Test blue tag"),
      // ItemTag(color: Colors.green, title: "Test green tag"),
    ],
  }) : id = id ?? DateTime.now().toString();

  Map<String, Object> toJson() {
    return {
      "id": id,
      "title": title,
      "checked": checked,
      "tags": "", // TODO: TAGS
      "unit": unit,
      "quantization": quantization,
      "currency": currency,
      "price": price,
      "amount": amount,
      "fractionDigits": quantizationDecimalNumbersAmount,
    };
  }

  static GroceryItem fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json["id"],
      amount: json["amount"],
      checked: json["checked"],
      currency: json["currency"],
      price: json["price"],
      quantization: json["quantization"],
      quantizationDecimalNumbersAmount: json["fractionDigits"],
      tags: <ItemTag>[], // TODO: TAGS
      title: json["title"],
      unit: json["unit"],
    );
  }

  GroceryItem copyWith({
    String id,
    String title,
    bool checked,
    List<ItemTag> tags,
    String unit,
    double quantization,
    int quantizationDecimalNumbersAmount,
    String currency,
    double price,
    double amount,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      checked: checked ?? this.checked,
      currency: currency ?? this.currency,
      quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount ?? this.quantizationDecimalNumbersAmount,
      price: price ?? this.price,
      quantization: quantization ?? this.quantization,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      unit: unit ?? this.unit,
    );
  }
}
