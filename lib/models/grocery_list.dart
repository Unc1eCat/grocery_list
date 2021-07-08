import 'grocery_item.dart';
import 'item_tag.dart';

class GroceryList {
  final String id;
  final List<GroceryItem> items;
  final List<ItemTag> tags;
  final String title;
  final String defaut_currency;
  final Set<GroceryItem> removedItems;

  GroceryList({
    Set<GroceryItem> removedItems,
    String id,
    List<GroceryItem> items,
    List<ItemTag> tags,
    this.title,
    this.defaut_currency,
  }) : this.id = id ?? DateTime.now().toString(), removedItems = removedItems ?? {}, items = items ?? [], tags = tags ?? [];
}
