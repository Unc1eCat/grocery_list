import 'package:flutter/cupertino.dart';

class GroceryItemExpansionController extends ChangeNotifier
{
  String _expandedGroceryItemId = null;
  bool _isProdcutEditingExpanded = false;

  String get expandedGroceryItemId => _expandedGroceryItemId;
  bool get isProductEditingExpanded => _isProdcutEditingExpanded;

  set expandedGroceryItemId(String val) {
    _expandedGroceryItemId = val;
    _isProdcutEditingExpanded = false;
    notifyListeners();
  }

   set isProductEditingExpanded(bool val) {
    _isProdcutEditingExpanded = val;
    notifyListeners();
  }
}