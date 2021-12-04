import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/widgets/rounded_rolling_switch.dart';
import 'package:grocery_list/widgets/searchg_result.dart';
import 'package:string_similarity/string_similarity.dart';
import 'dart:convert' as conv;
import 'dart:io';

import '../main.dart';
import '../models/grocery_prototype.dart';

// TODO: Make separate update state for every property of the grocery item
class GroceryListBloc extends Cubit<GroceryListState> {
  static GroceryListBloc of(BuildContext context) => BlocProvider.of<GroceryListBloc>(context);

  final List<Color> presetTagColors;

  List<GroceryPrototype> _prototypes = <GroceryPrototype>[];
  List<GroceryList> _lists = <GroceryList>[];

  List<GroceryList> get lists => _lists; //List<GroceryList>.unmodifiable(_lists);
  List<GroceryPrototype> get prototypes => List<GroceryPrototype>.unmodifiable(_prototypes);

  GroceryListBloc({
    this.presetTagColors = const [],
  }) : super(GroceryListState());
  GroceryListBloc.initFromFiles({
    this.presetTagColors = const [],
  }) : super(GroceryListState()) {}

  GroceryList getListOfId(String listId) => _lists?.firstWhere((e) => e.id == listId, orElse: () => null);
  GroceryItem getItemOfId(String id, String listId) => getListOfId(listId)?.items?.firstWhere((e) => e.id == id, orElse: () => null);
  GroceryPrototype getPrototypeOfId(String id) => _prototypes?.firstWhere((e) => e.id == id, orElse: () => null);
  ItemTag getTagOfId(String id, String listId) => getListOfId(listId)?.tags?.firstWhere((e) => e.id == id);

  @override
  onChange(Change change) {
    print("$this has emitted $change");
    super.onChange(change);
  }

  void saveItems() {}

  void savePrototypes() {}

  void addPrototype(GroceryPrototype prototype) {
    _prototypes.add(prototype);

    emit(ProductsListModifiedState());
  }

  GroceryPrototype getPrototypeOfTitle(String title) {
    return _prototypes.firstWhere((e) => e.title == title);
  }

  void removeProduct(String id) {
    _prototypes.removeWhere((e) => e.id == id);
    var changedIds = <String>{};

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].boundPrototype.id == id) {
          list.items[i] = list.items[i].copyWith(boundPrototype: null, updatePrototype: true);
          changedIds.add(list.items[i].id);
        }
      }
    }

    emit(ProductsListModifiedState());
    emit(ItemsChangedState(changedIds, true));

    savePrototypes();
  }

  void removeItemTag(String id, String listId) {
    ItemTag removed;
    getListOfId(listId).tags.removeWhere((e) {
      if (e.id == id) {
        removed = e;
        return true;
      }
      return false;
    });
    Set<String> changedItemsIds;

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].tags.contains(removed)) {
          list.items[i].tags.remove(removed);
          changedItemsIds.add(list.items[i].id);
        }
      }
    }

    emit(ItemsChangedState(changedItemsIds, true));

    savePrototypes();
  }

  void updatePrototype(GroceryPrototype newPrototype) {
    var index = _prototypes.indexWhere((e) => e.id == newPrototype.id);
    var changedItemsIds = <String>{};

    _prototypes[index] = newPrototype;

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].boundPrototype.id == newPrototype.id) {
          list.items[i] = list.items[i].copyWith(boundPrototype: newPrototype, updatePrototype: true);
          changedItemsIds.add(list.items[i].id);
        }
      }
    }

    emit(PrototypeChangedState(newPrototype));
    emit(ItemsChangedState(changedItemsIds, false));

    savePrototypes();
  }

  void moveList(int fromIndex, int toIndex) {
    _lists.insert(toIndex, _lists.removeAt(fromIndex));

    emit(ListsListModifiedState());
  }

  void moveItem(int fromIndex, int toIndex, String listId) {
    var list = getListOfId(listId);
    list.items.insert(toIndex, list.items.removeAt(fromIndex));

    emit(ItemMovedState(list.items, listId));

    saveItems();
  }

  void moveProduct(int fromIndex, int toIndex) {
    _prototypes.insert(toIndex, _prototypes.removeAt(fromIndex));

    emit(ProductsListModifiedState());
  }

  void moveItemTag(int fromIndex, int toIndex, String listId) {
    var list = getListOfId(listId);
    list.tags.insert(toIndex, list.tags.removeAt(fromIndex));

    emit(ItemTagsListModifiedState(listId));
  }

  int countItemsBoundToProduct(String id) {
    var ret = 0;

    for (var i in lists) {
      ret += i.items.where((e) => e.boundPrototype?.id == id).length;
    }

    return ret;
  }

  List<Widget> getSearchResults(String enteredText, String listId) {
    if (enteredText == "") return [];

    var list = getListOfId(listId);
    var increase = list.items.sublist(0);
    var fromProds = prototypes.sublist(0);

    increase.sort((a, b) => a.title.similarityTo(enteredText).compareTo(b.title.similarityTo(enteredText)));
    fromProds.sort((a, b) => a.title.similarityTo(enteredText).compareTo(b.title.similarityTo(enteredText)));

    return [
      SearchResultCreateProductless(name: enteredText, listId: listId),
      ...increase.take(3).map((e) => SearchResultIncreaseExisting(id: e.id, listId: listId)),
      SearchResultWithProduct(name: enteredText, listId: listId),
      ...fromProds.map((e) => SearchResultFromProduct(productId: e.id, listId: listId)).toList(),
    ];
  }

  bool containsPrototype(GroceryPrototype prototype) {
    return _prototypes.any((e) => e.id == prototype.id);
  }

  void addItem(GroceryItem newItem, String listId) {
    var list = getListOfId(listId);
    list.items.add(newItem);

    emit(ItemCreatedState(newItem.id, list.items, listId));

    saveItems();
  }

  void addItemTag(ItemTag newItemTag, String listId) {
    var list = getListOfId(listId);
    list.tags.add(newItemTag);

    emit(ItemTagsListModifiedState(listId));

    saveItems();
  }

  void removeItem(String id, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);

    emit(ItemDeletedState(list.items.removeAt(index), index, listId));

    saveItems();
  }

  void updateItem(String id, GroceryItem newItem, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);
    var oldItem = list.items[index];
    var updatedChecked = newItem.checked != oldItem.checked;
    var updatedProtBinding = newItem.boundPrototype?.id != oldItem.boundPrototype?.id;
    list.items[index] = newItem;

    emit(ItemsChangedState({id, oldItem.id}, updatedProtBinding));
    if (updatedChecked) {
      emit(CheckedChangedState(newItem.checked, newItem));
    }

    saveItems();
  }

  void addList(GroceryList list) {
    _lists.add(list);

    emit(ListsListModifiedState());
  }

  void removeList(String listId) {
    _lists.removeWhere((e) => e.id == listId);

    emit(ListsListModifiedState());
  }

  void updateList(String id, GroceryList newList) {
    var index = _lists.indexWhere((e) => e.id == id);
    _lists[index] = newList;

    emit(ListSettingsModifiedState(id));
  }

  void updateItemTag(String id, ItemTag newItemTag, String listId) {
    print("abobus");
    var list = getListOfId(listId);
    var index = list.tags.indexWhere((e) => e.id == id);
    list.tags[index] = newItemTag;
    Set<String> changedItemsIds = {};

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].tags.firstWhere((e) => e.id == id) != null) {
          list.items[i].tags[index] = newItemTag;
          changedItemsIds.add(list.items[i].id);
        }
      }
    }

    emit(ItemTagChangedState(listId, id));
  }

  Set<Color> getUnoccupiedTagColors(String listId) {
    return presetTagColors.toSet().difference(getListOfId(listId).tags.map((e) => e.color).toSet());
  }
}

// STATEs

class GroceryListState extends Equatable {
  @override
  List<Object> get props => [];
}

class WithinListState extends GroceryListState {
  final String listId;

  WithinListState(this.listId);

  @override
  List<Object> get props => super.props..add(listId);
}

class ItemsChangedState extends GroceryListState {
  final Set<String> changedIds;
  final bool reboundPrototype;

  ItemsChangedState(this.changedIds, this.reboundPrototype);

  @override
  List<Object> get props => super.props
    ..add(changedIds)
    ..add(reboundPrototype);

  bool contains(String id) => changedIds.contains(id);
}

class CheckedChangedState extends GroceryListState {
  final bool checked;
  final GroceryItem item;

  CheckedChangedState(this.checked, this.item);

  @override
  List<Object> get props => super.props
    ..add(checked)
    ..add(item);
}

class ItemDeletedState extends WithinListState {
  final GroceryItem removedItem;
  final int index;

  ItemDeletedState(this.removedItem, this.index, String listId) : super(listId);

  @override
  List<Object> get props => super.props..add(removedItem);
}

class ItemCreatedState extends WithinListState {
  final String id;
  final List<GroceryItem> items;

  ItemCreatedState(this.id, this.items, String listId) : super(listId);

  @override
  List<Object> get props => super.props
    ..add(id)
    ..add(items);
}

class ItemsFetchedState extends GroceryListState {
  final List<GroceryItem> items;

  ItemsFetchedState(this.items);

  @override
  List<Object> get props => super.props..add(items);
}

class ProductsListModifiedState extends GroceryListState {
  ProductsListModifiedState();

  bool operator ==(Object other) => false;
}

class PrototypeChangedState extends GroceryListState {
  final GroceryPrototype updatedPrototypes;

  PrototypeChangedState(this.updatedPrototypes);

  @override
  List<Object> get props => super.props..add(updatedPrototypes);
}

class ItemMovedState extends WithinListState {
  final List<GroceryItem> items;

  ItemMovedState(this.items, String listId) : super(listId);

  @override
  List<Object> get props => super.props..add(items);
}

class ListsListModifiedState extends GroceryListState {
  ListsListModifiedState();

  bool operator ==(Object other) => false;
}

class ListSettingsModifiedState extends WithinListState {
  ListSettingsModifiedState(String listId) : super(listId);
}

class ItemTagChangedState extends WithinListState {
  final String id;
  ItemTagChangedState(String listId, this.id) : super(listId);

  operator ==(Object other) => false;
}

class ItemTagsListModifiedState extends WithinListState {
  ItemTagsListModifiedState(String listId) : super(listId);

  bool operator ==(dynamic other) => false;
}
