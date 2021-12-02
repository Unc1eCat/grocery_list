import 'package:flutter/cupertino.dart';

class ProductsListController extends ChangeNotifier {
  String _expandedProductItemId = null;

  String get expandedProductItemId => _expandedProductItemId;

  set expandedProductItemId(String val) {
    _expandedProductItemId = val;
    notifyListeners();
  }
}
