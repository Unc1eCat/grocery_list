import 'package:flutter/cupertino.dart';

class GroceryListItemsExpansionController extends ChangeNotifier
{
  String _expandedGroceryListItemDetails = null;

  String get expandedGroceryListItemDetails => _expandedGroceryListItemDetails;

  set expandedGroceryListItemDetails(String val) {
    _expandedGroceryListItemDetails = val;
    notifyListeners();
  }
}