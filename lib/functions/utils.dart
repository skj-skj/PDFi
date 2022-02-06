// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';

// 📦 Package imports:
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';

/// ➕ Create 'doc_files' Folder if not exist
void createFolderIfNotExist() async {
  String storagePath = await getStoragePath();
  Directory docFilesDir = Directory(join(storagePath, kDOCFilesPath));
  if (!docFilesDir.existsSync()) {
    await docFilesDir.create(recursive: true);
  }
}

/// 🗑️🔥 Delete Cache Files
void deleteCache() async {
  try {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }

    /// ➕📁 Create Cache Directory after deleting it.
    cacheDir.createSync();
  } catch (e) {
    print(e);
    print("Cache Delete Error");
  }
}

/// 🗑️ Delete Specific File according to [path] from 'doc_files' 📁 Directory
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

/// ⚙️🔠, Generate String of Column Names seperated by ','
///
/// with or without bracket
///   - Use [withBrackert] : true/false
String genColStringForQuery(List<String> colNames,
    {required bool withBracket}) {
  String colString = colNames.toString();
  String colStringWithoutBracket = colString.substring(1, colString.length - 1);
  if (withBracket) {
    return '(' + colStringWithoutBracket + ')';
  }
  return colStringWithoutBracket;
}

/// 🗺️<🔡,🔠> Return Current App Info 
/// 
///   - App Version
///   - App Package Name
Future<Map<String, String>> getCurrAppInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Map<String, String> result = {
    "v": packageInfo.version,
    "pName": packageInfo.packageName,
  };
  return result;
}

/// [🗺️], Return [Map] from 🗄️ Database
///
/// Contains ['path','thumb'] Column
Future<List<Map>> getDOCDataFromDB() {
  DBHelper dbH = DBHelper();
  return dbH.queryForAllfilePaths();
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
    filePaths.add(filePath);
  }
  return filePaths;
}

/// ⏩ [🔡] Return Future [String,] containg path of files from 📁 Directory
Future<List<String>> getFilePathListFromDir() async {
  String storagePath = await getStoragePath();
  Directory docFilesDir = Directory(join(storagePath, kDOCFilesPath));
  List<FileSystemEntity> files = docFilesDir.listSync();
  //Map file to file.path and filter using where method if the file is Documents
  List<String> filePaths = files
      .map((file) => file.path)
      .where((filePath) => isDOC(filePath))
      .toList();
  return filePaths;
}

/// 🗺️<�,�🔠>, Get Updated App Version Number
Future<dynamic> getNewAppVersion({required Map<String, String> info}) async {
  return await http.get(Uri.parse(kCheckForUpdateURL)).then((res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body)[info['pName']];
    } else {
      print("Can't Able to fetch App Version");
      return kNullAppVersionJSON;
    }
  });
}

/// #️⃣ Return [SHA1] hash of [file]
Future<String> getSHA1Hash(File file) async {
  String hash = (await sha1.bind(file.openRead()).first).toString();
  // print(hash);
  return hash;
}

/// 📂 Returns External Storage Directory
Future<String> getStoragePath() async {
  Directory? storageDirectory = await getExternalStorageDirectory();
  return storageDirectory!.path;
}

///  Returns String, containig ⚙️ Generated SQLite Where Condition
String getWhereConditionForSearch(String text) {
  return "docText LIKE '%$text%' OR filename LIKE '%$text%' OR tags LIKE '%$text%'";
}

/// 🌐🧐 Checking Internet Is Available or Not
Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup("github.com");
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    print("Internet Error");
    print(e);
    return false;
  }
}

/// Return true is the file is of type Documents (pdf,xls,xlsx)
bool isDOC(String path) {
  return (isPDF(path) || isSpreadSheet(path) || isWordDoc(path));
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
  // print("hash: $hash");
  // print("hash DB: $hashFromDB");
  // print("IS Hash ${(hash == hashFromDB)}");
  return (hash == hashFromDB);
}

/// 0️⃣/1️⃣ Returns bool, is [path] have pdf extension or not
bool isPDF(String path) {
  return kPDFMimeType == lookupMimeType(path).toString();
}

/// 🧐 Is the File is SpreadSheet or not
bool isSpreadSheet(String path) {
  // print(
  //     "${lookupMimeType(path).toString()} ${kSpreadSheetMimeTypes.contains(lookupMimeType(path).toString())}");
  return kSpreadSheetMimeTypes.contains(lookupMimeType(path).toString());
}

/// 🧐 Is the File is Word Doc or not
bool isWordDoc(String path) {
  return kWordDocumentMimeTypes.contains(lookupMimeType(path).toString());
}

/// 📤 Extract Text From Docx File
String docxParser(File file){

  /// decoding docx as zip in 'docArchive'
  Archive docArchive = ZipDecoder().decodeBytes(file.readAsBytesSync());
  
  /// documentFile will store "word/document.xml"
  ArchiveFile? documentFile;

  /// loop to find "word/document.xml" and saving it to documentFile
  for (ArchiveFile file in docArchive.files){
    if (file.name == "word/document.xml"){
        documentFile = file;
        break;
    }
  }
  
  /// Extracting "word/document.xml" or 'documentFile' content as string
  String xmlContent = utf8.decode(documentFile!.content);
  
  /// Parsing xml
  XmlDocument xmlDocument = XmlDocument.parse(xmlContent);

  /// extracting all text in the 'xmlDocument' and all its node/element text inside the xml is seperated by space ' '.
  /// Empty text is excluded.
  String xmlTextContent = xmlDocument.descendants.where((node) => node is XmlText && node.text.trim().isNotEmpty).join(' ');
  // Limiting Number of Charaters to 5000 in 'xmlTextContent'
  if (xmlTextContent.length > 5000){
    xmlTextContent = xmlTextContent.substring(0,5001);
  }

  /// Returing text content from doc file
  return xmlTextContent;
}
