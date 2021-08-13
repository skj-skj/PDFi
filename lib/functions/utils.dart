// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';

/// ➕ Create 'pdf_files' Folder if not exist
void createFolderIfNotExist() async {
  String storagePath = await getStoragePath();
  Directory pdfFilesDir = Directory(join(storagePath, kPdfFilesPath));
  if (!pdfFilesDir.existsSync()) {
    await pdfFilesDir.create(recursive: true);
  }
}

/// 🗑️🔥 Delete Cache Files
void deleteCache() async {
  try {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  } catch (e) {
    print(e);
    print("Cache Delete Error");
  }
}

/// 🗑️ Delete Specific File according to [path] from 'pdf_files' 📁 Directory
void deleteFromDir(String path) {
  try {
    File file = File(path);
    file.deleteSync();
    print("Deleted");
  } catch (e) {
    print("Already Deleted");
    print(e);
  }
}

/// 🗃️ Return List of [Filename,Extension] used when Filename already exist in App Directory
List<String> getFileNameAndExtentionFromPath(String path) {
  String filename = getFileNameFromPath(path);
  List<String> filenameSplit = filename.split('.');
  int filenameSplitLength = filenameSplit.length;
  String filenameOnly = filenameSplit
      .sublist(0, filenameSplitLength - 1)
      .reduce((acc, curr) => acc + curr);
  String filenameExtension = filenameSplit.last;
  return [filenameOnly, filenameExtension];
}

/// 📄 return Filename from [path]
String getFileNameFromPath(String path) {
  return path.split('/').last;
}

/// 🔤 Return String Containing Singular or Plural of File according to [num]
String getFileOrFilesText(int num) {
  String text;
  if (num == 0) {
    return "No File";
  }
  if (num == 1) {
    text = "File";
  } else {
    text = "Files";
  }
  return "$num $text";
}

/// ⏩ [🔡] Return Future [String,] containg path of files from 🗄️ Database
Future<List<String>> getFilePathListFromDB() async {
  DBHelper dbHelper = DBHelper();
  List<Map> dbResult = await dbHelper.queryForAllfilePaths();
  List<String> filePaths = [];
  for (Map dbEntry in dbResult) {
    String filePath = dbEntry['path'];
    if (isPDF(filePath)) {
      filePaths.add(dbEntry['path']);
    }
  }
  return filePaths;
}

/// ⏩ [🔡] Return Future [String,] containg path of files from 📁 Directory
Future<List<String>> getFilePathListFromDir() async {
  String storagePath = await getStoragePath();
  Directory pdfFilesDir = Directory(join(storagePath, kPdfFilesPath));
  List<FileSystemEntity> files = pdfFilesDir.listSync();
  //Map file to file.path and filter using where method if the file is PDF
  List<String> filePaths = files
      .map((file) => file.path)
      .where((filePath) => isPDF(filePath))
      .toList();
  return filePaths;
}

/// [🗺️], Return [Map] from 🗄️ Database
///
/// Contains ['path','thumb'] Column
Future<List<Map>> getPDFDataFromDB() {
  DBHelper dbH = DBHelper();
  return dbH.queryForAllfilePaths();
}

/// #️⃣ Return [SHA1] hash of [file]
Future<String> getSHA1Hash(File file) async {
  String hash = (await sha1.bind(file.openRead()).first).toString();
  print(hash);
  return hash;
}

/// 📂 Returns External Storage Directory
Future<String> getStoragePath() async {
  Directory? storageDirectory = await getExternalStorageDirectory();
  return storageDirectory!.path;
}

/// 🔠 Returns String, containig ⚙️ Generated SQLite Where Condition
String getWhereConditionForSearch(String text) {
  return "pdfText LIKE '%$text%' OR filename LIKE '%$text%' OR tags LIKE '%$text%'";
}

/// 0️⃣/1️⃣ Returns bool, of is [filePath] exist in 📁 Directory or not
Future<bool> isFileExistInDir(String filePath) async {
  List<String> files = await getFilePathListFromDir();
  return files.contains(filePath);
}

/// 0️⃣/1️⃣ Returns bool, of is #️⃣ exists in the 🗄️ Database or not
Future<bool> isHashExists(File file) async {
  String hash = await getSHA1Hash(file);

  DBHelper dbHelper = DBHelper();
  String hashFromDB = await dbHelper.getSHA1HashDB(hash: hash);
  print("hash: $hash");
  print("hash DB: $hashFromDB");
  print("IS Hash ${(hash == hashFromDB)}");
  return (hash == hashFromDB);
}

/// 0️⃣/1️⃣ Returns bool, is [path] have pdf extension or not
bool isPDF(String path) {
  if (path.split('.').last.toLowerCase() == "pdf") {
    return true;
  } else {
    return false;
  }
}
