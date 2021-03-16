import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'dart:convert' as conv;
import 'dart:io';

import '../main.dart';

// TODO: Make separate update state for every property of the grocery item
class GroceryListBloc extends Cubit<GroceryListState> {
  Map<String, GroceryItem> _items = <String, GroceryItem>{};
  List<GroceryItem> _prototypes = <GroceryItem>[];

  Map<String, GroceryItem> get items => Map<String, GroceryItem>.unmodifiable(_items);
  List<GroceryItem> get prototypes => List<GroceryItem>.unmodifiable(_prototypes);

  GroceryItem getItemOfId(String id) => _items[id];

  GroceryListBloc(this._items) : super(GroceryListState());
  GroceryListBloc.initFromFiles() : super(GroceryListState()) {
    fetchItems();
  }

  Map<String, Object> toJsonItems() {
    var ret = <Map<String, Object>>[];

    for (var i in _items.values) {
      ret.add(i.toJson());
    }

    return {"grocery_item": ret};
  }

  void initItemsFromJson(Map<String, dynamic> json) {
    for (Map<String, dynamic> i in json["grocery_item"]) {
      GroceryItem item = GroceryItem.fromJson(i);
      _items.putIfAbsent(item.id, () => item);
    }
  }

  void saveItems() {
    TheApp.groceryItemsFile.writeAsStringSync(conv.jsonEncode(toJsonItems()));
  }

  void fetchItems() {
    try {
      initItemsFromJson(conv.jsonDecode(TheApp.groceryItemsFile.readAsStringSync()));
    } catch (exc) {
      print("Failed to fetch files from the file or the file is not initialized. Returning empty list");
      print(exc);

      _items = <String, GroceryItem>{};
    }

    emit(ItemsFetchedState(items));
  }

  void tryAddPrototype(GroceryItem item) {
    if (!containsPrototype(item)) {
      _prototypes.add(item);

      emit(PrototypeAddedState(prototypes, item));
    }
  }

  List<GroceryItem> getRelevantPrototypes(int limit, String enteredTitle) {
    if (_prototypes.length == 0) return <GroceryItem>[];

    List<GroceryItem> ret = _prototypes.sublist(0);

    print(ret);

    ret.removeWhere((e) => !e.title.contains(enteredTitle));
    ret.sort((a, b) => a.title.compareTo(b.title)); // Alphabetic
    ret.sort((a, b) => a.title.indexOf(enteredTitle).compareTo(b.title.indexOf(enteredTitle))); // Relevance

    return ret;

    // while (true)
    // {
    //   for (int i = 0; i < _prototypes.length; i++)
    //   {
    //     var v = _prototypes[i];
    //     var iRel = v.title.indexOf(enteredTitle);

    //     while (iRel > _prototypes[i + 1].title.indexOf(enteredTitle))
    //     {
    //       highestRel = iRel;

    //     }
    //   }
    // }
  }

  bool containsPrototype(GroceryItem prototype) {
    return _prototypes.any((e) =>
        e.title == prototype.title &&
        e.tags == prototype.tags &&
        e.price == prototype.price &&
        e.currency == prototype.currency &&
        e.unit == prototype.unit);
  }

  void createItem(GroceryItem newItem) {
    _items.putIfAbsent(newItem.id, () => newItem);

    emit(ItemCreatedState(newItem.id, items));

    saveItems();
  }

  void deleteItem(String id) {
    var index = _items.values.toList().indexWhere((e) => e.id == id);

    emit(ItemDeletedState(_items.remove(id), index));

    saveItems();
  }

  void updateItem(String id, GroceryItem newItem) {
    var updatedChecked = newItem.checked != _items[id].checked;
    _items.update(id, (value) => newItem);

    tryAddPrototype(newItem);

    emit(ItemChangedState(items, id));
    if (updatedChecked) {
      emit(CheckedChangedState(id, newItem.checked));
    }

    saveItems();
  }
}

// STATEs

class GroceryListState extends Equatable {
  @override
  List<Object> get props => [];
}

// class InitialState extends GroceryListState {}

class ItemChangedState extends GroceryListState {
  final Map<String, GroceryItem> items;
  final String id;

  ItemChangedState(this.items, this.id);

  @override
  List<Object> get props => super.props..add(items)..add(id);
}

class CheckedChangedState extends GroceryListState {
  final bool checked;
  final String id;

  CheckedChangedState(this.id, this.checked);

  @override
  List<Object> get props => super.props..add(checked)..add(id);
}

class ItemDeletedState extends GroceryListState {
  final GroceryItem removedItem;
  final int index;

  ItemDeletedState(this.removedItem, this.index);

  @override
  List<Object> get props => super.props..add(removedItem);
}

class ItemCreatedState extends GroceryListState {
  final String id;
  final Map<String, GroceryItem> items;

  ItemCreatedState(this.id, this.items);

  @override
  List<Object> get props => super.props..add(id)..add(items);
}

class ItemsFetchedState extends GroceryListState {
  final Map<String, GroceryItem> items;

  ItemsFetchedState(this.items);

  @override
  List<Object> get props => super.props..add(items);
}

class PrototypeAddedState extends GroceryListState {
  final List<GroceryItem> prototypes;
  final GroceryItem prototype;

  PrototypeAddedState(this.prototypes, this.prototype);

  @override
  List<Object> get props => super.props..add(prototypes)..add(prototype);
}
