// 🎯 Dart imports:
import 'dart:typed_data';

// 📦 Package imports:
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/doc_model.dart';

/// 🗄️🛠️ Database Helper Class
class DBHelper {
  /// 🗄️ [Database?] 🗿 🕵️ variable
  static Database? _db;

  /// 🗞️ getter for [_db], which initiate Database if null
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      Database db = await initDB();
      return db;
    }
  }

  /// 🗑️ Delete Row by [filename] from 🗄️ Database
  void deleteFromFilename(String filename) async {
    Database? dbClient = await db;
    int rowsDeleted = await dbClient!
        .delete(kDOCTableName, where: "filename = ?", whereArgs: [filename]);
    print("$rowsDeleted Rows Deleted");
  }

  /// 🗑️ Delete Row by [path] from 🗄️ Database
  void deleteFromPath(String path) async {
    Database? dbClient = await db;
    int rowsDeleted = await dbClient!
        .delete(kDOCTableName, where: "path = ?", whereArgs: [path]);
    print("$rowsDeleted Rows Deleted");
  }

  /// ⏩🔠 Return String, containing [folder] data
  ///
  /// Where path = [path]
  Future<String> getFolder({required String path}) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!
        .query(kDOCTableName, columns: ['folder'], where: "path = '$path'");
    if (results.length > 0) {
      return results[0]['folder'];
    } else {
      return '';
    }
  }

  /// ⏩#️⃣ Return String, containing [hash] String
  ///
  /// Where hash = [hash]
  /// if hash doesn't exist return empty String ''
  Future<String> getSHA1HashDB({required String hash}) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!
        .query(kDOCTableName, columns: ['hash'], where: "hash = '$hash'");
    print(results);
    if (results.length > 0) {
      return results[0]['hash'];
    } else {
      return '';
    }
  }

  /// ⏩🏷️ Return String, containing [tags] data
  ///
  /// Where path = [path]
  Future<String> getTags({required String path}) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!
        .query(kDOCTableName, columns: ['tags'], where: "path = '$path'");
    if (results.length > 0) {
      return results[0]['tags'];
    } else {
      return '';
    }
  }

  /// 🖼️ Return Thumnail form 🗄️ Database
  Future<Uint8List?> getThumbnail(String path) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!
        .query(kDOCTableName, columns: ['thumb'], where: "path = '$path");
    if (results.length > 0) {
      return results[0]['thumb'];
    } else {
      return null;
    }
  }

  /// ⏩🗄️ Return Database
  ///
  /// It open Database in 📁 Directory and Create Table in 🗄️ Database on first run
  Future<Database> initDB() async {
    String storagePath = await Utils.getStoragePath();
    Database db = await openDatabase(join(storagePath, kDBFileName),
        version: 1, onCreate: _onCreate);
    return db;
  }

  /// ⏩📟 Return Total No of Rows in the 🗄️ Database Table
  Future<int> noOfRows() async {
    Database? dbClient = await db;
    List<Map> results =
        await dbClient!.rawQuery("SELECT COUNT(*) FROM $kDOCTableName");
    return results[0]["COUNT(*)"];
  }

  /// ⏩[🗺️] Return [Map,]
  ///
  /// Return [path,thumb] from all Rows
  Future<List<Map>> queryForAllfilePaths() async {
    Database? dbClient = await db;
    return await dbClient!
        .query(kDOCTableName, columns: ['path', 'thumb'], orderBy: kPathAsc);
  }

  /// ⏩[🗺️] Return [Map,]
  ///
  /// Return [path,thumb] from Rows
  ///
  /// Where [docText,filename,tags] from 🗄️ Database Table contains 🔠 [text]
  Future<List<Map>> queryForFilePathsWithCondition(String text) async {
    Database? dbClient = await db;
    return await dbClient!.query(
      kDOCTableName,
      columns: ['path', 'thumb'],
      where: Utils.getWhereConditionForSearch(text),
      orderBy: kPathAsc,
    );
  }

  /// 📥 Save [folder] data in the 🗄️ Database
  void saveFolder({required String path, required String folder}) async {
    Database? dbClient = await db;
    dbClient!
        .update(kDOCTableName, {'folder': '$folder'}, where: "path = '$path'");
  }

  /// 📥 Save [docModel] data in the 🗄️ Database
  void saveDOC(DOCModel docModel) async {
    Database? dbClient = await db;
    dbClient!.insert(kDOCTableName, docModel.toMap());
  }

  /// 📥 Save [tags] data in the 🗄️ Database
  void saveTags({required String path, required String tags}) async {
    Database? dbClient = await db;
    dbClient!.update(kDOCTableName, {'tags': '$tags'}, where: "path = '$path'");
  }

  /// ➕ Create 🗄️ Database Table if not Created
  void _onCreate(Database db, int version) async {
    await db.execute(kCreateTableQuery);
  }

  /// [🔠], Return List of Table Names from the 🗄️ Database
  Future<List<String>> getTableNames() async {
    Database? dbClient = await db;
    List<Map> result = await dbClient!.rawQuery('''
    SELECT name FROM sqlite_master 
    WHERE type = 'table' AND 
    name NOT LIKE 'sqlite_%' AND 
    name LIKE '%table%'
    ''');

    List<String> tableNames = result.map((e) => e['name'].toString()).toList();
    return tableNames;
  }

  /// [🔠], Return List of Column names of the Table
  Future<List<String>> getTableColumn(String tableName) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!.rawQuery('''
      PRAGMA table_info($tableName)
    ''');
    List<String> colNames = results.map((e) => e['name'].toString()).toList();
    return colNames;
  }

  /// 🗄️➡️🗄️, Clone data of one table to another
  ///
  /// Schema of both tables must be same
  Future<void> cloneTable(
      {required String srcTable, required String destTable}) async {
    List<String> srcTableCol = await getTableColumn(srcTable);
    List<String> destTableCol = await getTableColumn(destTable);
    Database? dbClient = await db;
    try {
      await dbClient!.rawQuery('''
      INSERT INTO $destTable ${Utils.genColStringForQuery(destTableCol, withBracket: true)}
      SELECT ${Utils.genColStringForQuery(srcTableCol, withBracket: false)}
      FROM $srcTable
    ''');
    } catch (e) {
      print("Error in Cloning Table");
      print(e);
    }
  }

  /// 🗑️🔥 Drop the Table from the 🗄️ Database
  Future<void> dropTable(String tableName) async {
    Database? dbClient = await db;
    await dbClient!.rawQuery('''
      DROP TABLE IF EXISTS
        $tableName
    ''');
  }

  /// ➕ Create 'doc_table' table if not exist
  ///
  /// this function is likely to be called when the app is using old table
  Future<void> creatDOCTable() async {
    Database? dbClient = await db;
    await dbClient!.rawQuery('''
    CREATE TABLE IF NOT EXISTS $kDOCTableName (
	    filename TEXT PRIMARY KEY,
      path TEXT,
      thumb BLOB,
  	  docText TEXT,
  	  tags TEXT,
      hash TEXT,
      folder TEXT
    )
    ''');
  }
}
