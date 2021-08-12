// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/widgets/item.dart';

/// 🧰🔁, [PDFItemModel] for State Management
///
/// items = [Item,]
///   - Items => 💄 Widget
class PDFItemModel extends ChangeNotifier {
  /// 🕵️ [_items], Stores [Items,]
  ///
  /// Items => 💄 Widget
  List<Item> _items = [];

  /// 🗞️ Getter for [_items]
  ///
  /// calls [fetchItems()] if _items = []
  List<Item> get items {
    if (_items.length > 0) {
      return _items;
    } else {
      fetchItems();
      return _items;
    }
  }

  /// 🗑️ Delete Item contains this [path]
  void deleteItems(String path) {
    _items = _items.where((item) => item.path != path).toList();

    // 🔈 Notifying Listeners
    notifyListeners();
  }

  /// ⏩🗞️, fetch items from the 🗄️ databse
  ///
  /// Stores in [_items]
  Future<void> fetchItems() async {
    DBHelper dbHelper = DBHelper();
    List<Item> tempItems = [];
    List<Map> dbResult = await dbHelper.queryForAllfilePaths();
    for (Map dbResultItem in dbResult) {
      tempItems.add(Item(path: dbResultItem['path']));
    }
    _items = tempItems;

    // 🔈 Notifying Listeners
    notifyListeners();
  }

  /// ➕ Update [_items]
  ///
  /// From [🗺️], Contains 🗄️ Database Rows
  void updateItem(List<Map> dbResultItems) {
    _items = [];
    for (Map dbResultItem in dbResultItems) {
      _items.add(Item(path: dbResultItem['path']));
    }
    notifyListeners();
  }

  /// ➕ Update [_items]
  ///
  /// From [🔠], Contains [filePaths] from the 🗄️ Database
  void updateItemFromList(List<String> filePaths) {
    _items = [];

    // 💱 Mapped 🔠 filepath to 💄 Item(path: filePath) Widget
    // 📥 added in [_items]
    _items.addAll((filePaths.map((filePath) => Item(path: filePath))));

    // 🔈 Notifying Listeners
    notifyListeners();
  }
}
