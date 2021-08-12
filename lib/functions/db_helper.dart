// 📦 Package imports:
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfModel.dart';

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
        .delete(kPdfTableName, where: "filename = ?", whereArgs: [filename]);
    print("$rowsDeleted Rows Deleted");
  }

  /// 🗑️ Delete Row by [path] from 🗄️ Database
  void deleteFromPath(String path) async {
    Database? dbClient = await db;
    int rowsDeleted = await dbClient!
        .delete(kPdfTableName, where: "path = ?", whereArgs: [path]);
    print("$rowsDeleted Rows Deleted");
  }

  /// ⏩🔠 Return String, containing [folder] data
  ///
  /// Where path = [path]
  Future<String> getFolder({required String path}) async {
    Database? dbClient = await db;
    List<Map> results = await dbClient!
        .query(kPdfTableName, columns: ['folder'], where: "path = '$path'");
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
        .query(kPdfTableName, columns: ['hash'], where: "hash = '$hash'");
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
        .query(kPdfTableName, columns: ['tags'], where: "path = '$path'");
    if (results.length > 0) {
      return results[0]['tags'];
    } else {
      return '';
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

  /// ⏩[🗺️] Return [Map,]
  ///
  /// Return [path] from all Rows
  Future<List<Map>> queryForAllfilePaths() async {
    Database? dbClient = await db;
    return await dbClient!
        .query(kPdfTableName, columns: ['path'], orderBy: kPathAsc);
  }

  /// ⏩[🗺️] Return [Map,]
  ///
  /// Return [path] from Rows
  /// Where pdfText,filename,tags contains [text]
  Future<List<Map>> queryForFilePathsWithCondition(String text) async {
    Database? dbClient = await db;
    return await dbClient!.query(
      kPdfTableName,
      columns: ['path'],
      where: Utils.getWhereConditionForSearch(text),
      orderBy: kPathAsc,
    );
  }

  /// 📥 Save [folder] data in the 🗄️ Database
  void saveFolder({required String path, required String folder}) async {
    Database? dbClient = await db;
    dbClient!
        .update(kPdfTableName, {'folder': '$folder'}, where: "path = '$path'");
  }

  /// 📥 Save [pdfModel] data in the 🗄️ Database
  void savePdf(PDFModel pdfModel) async {
    Database? dbClient = await db;
    dbClient!.insert(kPdfTableName, pdfModel.toMap());
  }

  /// 📥 Save [tags] data in the 🗄️ Database
  void saveTags({required String path, required String tags}) async {
    Database? dbClient = await db;
    dbClient!.update(kPdfTableName, {'tags': '$tags'}, where: "path = '$path'");
  }

  /// ➕ Create 🗄️ Database Table if not Created
  void _onCreate(Database db, int version) async {
    await db.execute(kCreateTableQuery);
  }
}
