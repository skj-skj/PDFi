// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π Project imports:
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/widgets/item.dart';

/// π§°π, [DOCItemModel] for State Management
///
/// items = [Item,]
///   - Items => π Widget
class DOCItemModel extends ChangeNotifier {
  /// π΅οΈ [_items], Stores [Items,]
  ///
  /// Items => π Widget
  List<Item> _items = [];

  /// 0οΈβ£/1οΈβ£ [_isFirstRun]
  ///
  /// Does the app running for the first time
  bool _isFirstRun = true;

  /// ποΈ Getter for [_items]
  ///
  /// calls [fetchItems()] if _items = []
  List<Item> get items {
    if (_isFirstRun) {
      fetchItems();
    }
    return _items;
  }

  /// ποΈ Delete Item contains this [path]
  void deleteItems(String path) {
    _items = _items.where((item) => item.path != path).toList();

    // π Notifying Listeners
    notifyListeners();
  }

  /// β©ποΈ, fetch items from the ποΈ databse
  ///
  /// Stores π [Item(path,thumb)] in [_items]
  Future<void> fetchItems() async {
    DBHelper dbHelper = DBHelper();
    List<Item> tempItems = [];
    List<Map> dbResult = await dbHelper.queryForAllfilePaths();
    for (Map dbResultItem in dbResult) {
      tempItems.add(
        Item(
          path: dbResultItem['path'],
          thumb: dbResultItem['thumb'],
        ),
      );
    }
    _isFirstRun = false;
    print('first run');
    _items = tempItems;

    // π Notifying Listeners
    notifyListeners();
  }

  /// β Update [_items]
  ///
  /// From [πΊοΈ], Contains ποΈ Database Rows
  void updateItem(List<Map> dbResultItems) {
    _items = [];

    for (Map dbResultItem in dbResultItems) {
      _items.add(Item(
        path: dbResultItem['path'],
        thumb: dbResultItem['thumb'],
      ));
    }

    notifyListeners();
  }

  /// β Update [_items]
  ///
  /// From [π ], Contains [filePaths] from the ποΈ Database
  // void updateItemFromList(List<String> filePaths) {
  //   _items = [];

  //   // π± Mapped π  filepath to π Item(path: filePath) Widget
  //   // π₯ added in [_items]
  //   _items.addAll((filePaths.map((filePath) => Item(path: filePath))));

  //   // π Notifying Listeners
  //   notifyListeners();
  // }
}
