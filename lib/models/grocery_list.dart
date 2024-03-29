import 'package:flutter/material.dart';
import 'package:grocery_list/utils/serealization_utils.dart';

import 'grocery_item.dart';
import 'item_tag.dart';

class GroceryList implements ToJson {
  final String id;
  final List<GroceryItem> items;
  final List<ItemTag> tags;
  final String title;
  final String defaultCurrency;
  final Set<GroceryItem> purchasedItems;
  final bool usePrice;

  GroceryList({
    this.usePrice = true,
    Set<GroceryItem> removedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    this.title,
    this.defaultCurrency = "",
  })  : this.id = id ?? DateTime.now().toString(),
        purchasedItems = removedItems ?? {},
        items = items ?? [],
        tags = tags ?? [];

  GroceryList.fromJson(Map<String, Object> json)
      : id = json["id"],
        items = (json["items"] as List<Map<String, Object>>).map((e) => GroceryItem.fromJson(e)).toList(),
        tags = (json["tags"] as List<Map<String, Object>>).map((e) => ItemTag.fromJson(e)).toList(),
        title = json["title"],
        defaultCurrency = json["defaultCurrency"],
        purchasedItems = (json["purchasedItems"] as List<Map<String, Object>>).map((e) => GroceryItem.fromJson(e)).toSet(),
        usePrice = json["purchasedItems"];

  GroceryList copyWith({
    bool usePrice,
    Set<GroceryItem> purchasedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    String title,
    String defaultCurrency,
  }) =>
      GroceryList(
          id: id ?? this.id,
          title: title ?? this.title,
          defaultCurrency: defaultCurrency ?? this.defaultCurrency,
          items: items ?? this.items,
          removedItems: purchasedItems ?? this.purchasedItems,
          usePrice: usePrice ?? this.usePrice);

  @override
  Map<String, Object> toJson() => {
        "id": id,
        "items": items,
        "tags": tags,
        "title": title,
        "defaultCurrency": defaultCurrency,
        "purchasedItems": purchasedItems,
        "usePrice": usePrice,
      };
}
