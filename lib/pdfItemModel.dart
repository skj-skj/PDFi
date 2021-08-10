import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/widgets/item.dart';

class PDFItemModel extends ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items {
    if (_items.length > 0) {
      return _items;
    } else {
      fetchItems();
      return _items;
    }
  }

  void deleteItems(String path) {
    _items = _items.where((item) => item.path != path).toList();

    notifyListeners();
  }

  Future<void> fetchItems() async {
    DBHelper dbHelper = DBHelper();
    List<Item> tempItems = [];
    List<Map> dbResult = await dbHelper.queryForAllfilePaths();
    for (Map dbResultItem in dbResult) {
      tempItems.add(Item(path: dbResultItem['path']));
    }
    _items = tempItems;
    notifyListeners();
  }

  //Update Item from List<String> containing list of file paths
  void updateItem(List<Map> dbResultItems) {
    _items = [];
    for (Map dbResultItem in dbResultItems) {
      _items.add(Item(path: dbResultItem['path']));
    }
    notifyListeners();
  }

  void updateItemFromList(List<String> filePaths) {
    _items = [];
    // Mapped filepath to Item(path: filePath) wiget and stored it into items list
    _items.addAll((filePaths.map((filePath) => Item(path: filePath))));
    notifyListeners();
  }

  // void notify() {
  //   notifyListeners();
  // }
}
