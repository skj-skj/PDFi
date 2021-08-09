import 'package:path/path.dart';
import 'package:pdf_indexing/constants.dart';
// import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:pdf_indexing/pdfModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      Database db = await initDB();
      return db;
    }
  }

  Future<Database> initDB() async {
    String storagePath = await Utils.getStoragePath();
    Database db = await openDatabase(join(storagePath, kDBFileName),
        version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(kCreateTableQuery);
  }

  void savePdf(PDFModel pdfModel) async {
    Database? dbClient = await db;
    dbClient!.insert(kPdfTableName, pdfModel.toMap());
  }

  //Select query for all file paths
  Future<List<Map>> queryForAllfilePaths() async {
    Database? dbClient = await db;
    return await dbClient!
        .query(kPdfTableName, columns: ['path'], orderBy: kPathAsc);
  }

  //Select query for file paths with where condition - seaching in the text column
  Future<List<Map>> queryForFilePathsWithCondition(String text) async {
    Database? dbClient = await db;
    return await dbClient!.query(
      kPdfTableName,
      columns: ['path'],
      where: Utils.getWhereConditionForSearch(text),
      orderBy: kPathAsc,
    );
  }

  // Select query for getting sha1 hash entry of the file
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

  void deleteFromPath(String path) async {
    Database? dbClient = await db;
    int rowsDeleted = await dbClient!
        .delete(kPdfTableName, where: "path = ?", whereArgs: [path]);
    print("$rowsDeleted Rows Deleted");
  }

  void deleteFromFilename(String filename) async {
    Database? dbClient = await db;
    int rowsDeleted = await dbClient!
        .delete(kPdfTableName, where: "filename = ?", whereArgs: [filename]);
    print("$rowsDeleted Rows Deleted");
  }
}
