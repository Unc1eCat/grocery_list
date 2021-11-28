import 'grocery_item.dart';
import 'item_tag.dart';

class GroceryList {
  final String id;
  final List<GroceryItem> items;
  final List<ItemTag> tags;
  final String title;
  final String default_currency;
  final Set<GroceryItem> removedItems;

  GroceryList({
    Set<GroceryItem> removedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    this.title,
    this.default_currency,
  })  : this.id = id ?? DateTime.now().toString(),
        removedItems = removedItems ?? {},
        items = items ?? [],
        tags = tags ?? [];

  GroceryList copyWith({
    Set<GroceryItem> removedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    String title,
    String default_currency,
  }) =>
      GroceryList(
        id: id ?? this.id,
        title: title ?? this.title,
        default_currency: default_currency ?? this.default_currency,
      );
}
