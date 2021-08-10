import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';

void createFolderIfNotExist() async {
  String storagePath = await getStoragePath();
  Directory pdfFilesDir = Directory(join(storagePath, kPdfFilesPath));
  if (!pdfFilesDir.existsSync()) {
    await pdfFilesDir.create(recursive: true);
  }
}

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

String getFileNameFromPath(String path) {
  return path.split('/').last;
}

//Where Condition for Searching
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

// Is the file is pdf or the name have .pdf extension
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

// Get list of file path from the "pdf_files" folder/directory
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

// Get list of file path from the Database
Future<String> getSHA1Hash(File file) async {
  String hash = (await sha1.bind(file.openRead()).first).toString();
  print(hash);
  return hash;
}

// Bool - return status of DB, is it empty or not

//Bool - if File Name exist in the directory
Future<String> getStoragePath() async {
  Directory? storageDirectory = await getExternalStorageDirectory();
  return storageDirectory!.path;
}

String getWhereConditionForSearch(String text) {
  return "pdfText LIKE '%$text%' OR filename LIKE '%$text%' OR tags LIKE '%$text%'";
}

// String - Get sha1 hash
Future<bool> isFileExistInDir(String filePath) async {
  List<String> files = await getFilePathListFromDir();
  return files.contains(filePath);
}

//Bool - Is File hash exists in the DB
Future<bool> isHashExists(File file) async {
  String hash = await getSHA1Hash(file);

  DBHelper dbHelper = DBHelper();
  String hashFromDB = await dbHelper.getSHA1HashDB(hash: hash);
  print("hash: $hash");
  print("hash DB: $hashFromDB");
  print("IS Hash ${(hash == hashFromDB)}");
  return (hash == hashFromDB);
}

// Delete file from the folder / directory
bool isPDF(String path) {
  if (path.split('.').last.toLowerCase() == "pdf") {
    return true;
  } else {
    return false;
  }
}
