import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/models/grocery_list.dart';
import 'package:grocery_list/models/grocery_prototype.dart';
import 'package:grocery_list/models/item_tag.dart';
import 'package:grocery_list/utils/app_directories.dart';
import 'package:grocery_list/utils/serealization_utils.dart';
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

  void saveLists() async {
    print(jsonEncoder.convert(_lists));
  }

  void savePrototypes() async {}

  void addPrototype(GroceryPrototype prototype) {
    _prototypes.add(prototype);

    emit(ProductsListModifiedState());

    savePrototypes();
  }

  GroceryPrototype getPrototypeOfTitle(String title) {
    return _prototypes.firstWhere((e) => e.title == title);
  }

  void removeProduct(String id) {
    _prototypes.removeWhere((e) => e.id == id);
    var previousItems = <GroceryItem>{};

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].boundPrototype?.id == id) {
          previousItems.add(list.items[i]);
          list.items[i] = list.items[i].copyWith(boundPrototype: null, updatePrototype: true);
        }
      }
    }

    emit(ProductsListModifiedState());
    emit(ItemsChangedState(true, previousItems));

    savePrototypes();
    saveLists();
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

    var previousItems = <GroceryItem>{};

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].tags.contains(removed)) {
          previousItems.add(list.items[i]);
          list.items[i].tags.remove(removed);
        }
      }
    }

    emit(ItemsChangedState(true, previousItems));

    saveLists();
  }

  void updatePrototype(GroceryPrototype newPrototype) {
    var index = _prototypes.indexWhere((e) => e.id == newPrototype.id);
    var previousItems = <GroceryItem>{};

    _prototypes[index] = newPrototype;

    for (var list in _lists) {
      for (var i = 0; i < list.items.length; i++) {
        if (list.items[i].boundPrototype?.id == newPrototype.id) {
          previousItems.add(list.items[i]);
          list.items[i] = list.items[i].copyWith(boundPrototype: newPrototype, updatePrototype: true).copyWithAmountSnappedToQuantization();
        }
      }
    }

    emit(PrototypeChangedState(newPrototype));
    emit(ItemsChangedState(false, previousItems));

    savePrototypes();
    saveLists();
  }

  void moveList(int fromIndex, int toIndex) {
    _lists.insert(toIndex, _lists.removeAt(fromIndex));

    emit(ListsListModifiedState());

    saveLists();
  }

  void moveItem(int fromIndex, int toIndex, String listId) {
    var list = getListOfId(listId);
    list.items.insert(toIndex, list.items.removeAt(fromIndex));

    emit(ItemMovedState(list.items, listId));

    saveLists();
  }

  void moveProduct(int fromIndex, int toIndex) {
    _prototypes.insert(toIndex, _prototypes.removeAt(fromIndex));

    emit(ProductsListModifiedState());

    savePrototypes();
  }

  void moveItemTag(int fromIndex, int toIndex, String listId) {
    var list = getListOfId(listId);
    list.tags.insert(toIndex, list.tags.removeAt(fromIndex));

    emit(ItemTagsListModifiedState(listId));

    saveLists();
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

    emit(ItemCreatedState(newItem.id, listId));

    if (newItem.boundPrototype != null) {
      emit(AmountOfItemsOfProductChangedState(newItem.boundPrototype.id, countItemsBoundToProduct(newItem.boundPrototype.id)));
    }

    saveLists();
  }

  void addItemTag(ItemTag newItemTag, String listId) {
    var list = getListOfId(listId);
    list.tags.add(newItemTag);

    emit(ItemTagsListModifiedState(listId));

    saveLists();
  }

  void removeItem(String id, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);
    var removedItem = list.items.removeAt(index);

    emit(ItemDeletedState(removedItem, index, listId));

    if (removedItem.boundPrototype != null) {
      emit(AmountOfItemsOfProductChangedState(removedItem.boundPrototype.id, countItemsBoundToProduct(removedItem.boundPrototype.id)));
    }

    saveLists();
  }

  void updateItem(String id, GroceryItem newItem, String listId) {
    var list = getListOfId(listId);
    var index = list.items.indexWhere((e) => e.id == id);
    var oldItem = list.items[index];
    var updatedChecked = newItem.checked != oldItem.checked;
    var updatedProtBinding = newItem.boundPrototype?.id != oldItem.boundPrototype?.id;
    list.items[index] = newItem;

    emit(ItemsChangedState(updatedProtBinding, {oldItem}));

    if (updatedChecked) {
      emit(CheckedChangedState(newItem.checked, newItem));
    }

    if (updatedProtBinding) {
      if (oldItem.boundPrototype != null) {
        emit(AmountOfItemsOfProductChangedState(oldItem.boundPrototype.id, countItemsBoundToProduct(oldItem.boundPrototype.id)));
      }
      if (newItem.boundPrototype != null) {
        emit(AmountOfItemsOfProductChangedState(newItem.boundPrototype.id, countItemsBoundToProduct(newItem.boundPrototype.id)));
      }
    }

    saveLists();
  }

  void addList(GroceryList list) {
    _lists.add(list);

    emit(ListsListModifiedState());

    saveLists();
  }

  void removeList(String listId) {
    _lists.removeWhere((e) => e.id == listId);

    emit(ListsListModifiedState());

    saveLists();
  }

  void updateList(String id, GroceryList newList) {
    var index = _lists.indexWhere((e) => e.id == id);
    _lists[index] = newList;

    emit(ListSettingsModifiedState(id));

    saveLists();
  }

  void updateItemTag(String id, ItemTag newItemTag, String listId) {
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

    saveLists();
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
  final bool reboundPrototype;
  final Set<GroceryItem> previous;

  ItemsChangedState(this.reboundPrototype, this.previous);

  @override
  List<Object> get props => super.props
    ..add(previous)
    ..add(reboundPrototype);

  bool operator ==(dynamic other) => false;

  bool contains(String id) => previousOfId(id) != null;

  GroceryItem previousOfId(String id) => previous.firstWhere((e) => e.id == id, orElse: () => null);
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

  ItemCreatedState(
    this.id,
    String listId,
  ) : super(listId);

  @override
  List<Object> get props => super.props..add(id);
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
  final GroceryPrototype previous;

  PrototypeChangedState(this.previous);

  @override
  List<Object> get props => super.props..add(previous);
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

class AmountOfItemsOfProductChangedState extends GroceryListState {
  final String productId;
  final int amount;

  AmountOfItemsOfProductChangedState(this.productId, this.amount);

  @override
  List<Object> get props => super.props
    ..add(productId)
    ..add(amount);
}
