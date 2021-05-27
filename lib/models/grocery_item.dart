import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';

abstract class GroceryItem {
  String get id;
  String get title;
  bool get checked;
  List<ItemTag> get tags;
  String get unit;
  double get quantization;
  int get quantizationDecimalNumbersAmount;
  String get currency;
  double get price;
  double get amount;
  String get boundPrototypeId;

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
    String boundPrototypeId,
    bool updatePrototype = false,
  });
}

@immutable
class ProductlessGroceryItem implements GroceryItem {
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
  final String boundPrototypeId;

  ProductlessGroceryItem({
    String id,
    this.unit = "it.",
    this.quantization = 1.0,
    this.quantizationDecimalNumbersAmount = 0,
    this.currency = "₽",
    this.price = 0.0,
    this.amount = 0.0,
    this.title = "New item",
    this.checked = false,
    this.boundPrototypeId,
    this.tags = const [
      // ItemTag(color: Colors.red, title: "Test red tag"),
      // ItemTag(color: Colors.blue, title: "Test blue tag"),
      // ItemTag(color: Colors.green, title: "Test green tag"),
    ],
  }) : id = id ?? DateTime.now().toString();

  // Map<String, Object> toJson() {
  //   return boundPrototypeId == null
  //       ? {
  //           "id": id,
  //           "title": title,
  //           "checked": checked,
  //           "tags": "", // TODO: TAGS
  //           "unit": unit,
  //           "quantization": quantization,
  //           "currency": currency,
  //           "price": price,
  //           "amount": amount,
  //           "fractionDigits": quantizationDecimalNumbersAmount,
  //         }
  //       : {
  //           "id": id,
  //           "checked": checked,
  //           "amount": amount,
  //           "boundPrototypeId": boundPrototype.id,
  //         };
  // }

  // static GroceryItem fromJson(Map<String, dynamic> json) {
  //   if (json.containsKey("boundPrototypeId")) {
  //     return GroceryItem(
  //       id: json["id"],
  //       amount: json["amount"],
  //       checked: json["checked"],
  //       boundPrototype: json["boundPrototypeId"],
  //     );
  //   } else {
  //     return GroceryItem(
  //       id: json["id"],
  //       amount: json["amount"],
  //       checked: json["checked"],
  //       currency: json["currency"],
  //       price: json["price"],
  //       quantization: json["quantization"],
  //       quantizationDecimalNumbersAmount: json["fractionDigits"],
  //       tags: <ItemTag>[], // TODO: TAGS
  //       title: json["title"],
  //       unit: json["unit"],
  //     );
  //   }
  // }

  @override
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
    String boundPrototypeId,
    bool updatePrototype = false,
  }) {
    bool wontHavePrototype = updatePrototype ? boundPrototypeId == null : this.boundPrototypeId == null;
    return wontHavePrototype
        ? ProductlessGroceryItem(
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
            boundPrototypeId: updatePrototype ? boundPrototypeId : this.boundPrototypeId,
          )
        : null;
  }

  GroceryPrototype createPrototype({String id}) {
    return GroceryPrototype(
      id: id,
      currency: currency,
      price: price,
      quantization: quantization,
      quantizationDecimalNumbersAmount: quantizationDecimalNumbersAmount,
      tags: tags,
      title: title,
      unit: unit,
    );
  }
}

class ProductfulGroceryItem implements GroceryItem {
  @override
  double get amount => throw UnimplementedError();

  @override
  String get boundPrototypeId => throw UnimplementedError();

  @override
  bool get checked => throw UnimplementedError();

  

  @override
  String get currency => throw UnimplementedError();

  @override
  String get id => throw UnimplementedError();

  @override
  double get price => throw UnimplementedError();

  @override
  double get quantization => throw UnimplementedError();

  @override
  int get quantizationDecimalNumbersAmount => throw UnimplementedError();

  @override
  List<ItemTag> get tags => throw UnimplementedError();

  @override
  String get title => throw UnimplementedError();

  @override
  String get unit => throw UnimplementedError();
  
  @override
  GroceryItem copyWith(
      {String id,
      String title,
      bool checked,
      List<ItemTag> tags,
      String unit,
      double quantization,
      int quantizationDecimalNumbersAmount,
      String currency,
      double price,
      double amount,
      String boundPrototypeId,
      bool updatePrototype = false}) {
    throw UnimplementedError();
  }
}
