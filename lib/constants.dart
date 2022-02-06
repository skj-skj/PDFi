// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/model/doc_model.dart';

/// 🗺️<🔡,🔠>, Map of Image URI with their Documents Type
Map<String, String> assetMap = {
  'file_error': kFileErrorImage,
  'xlsx': kXLSXFileIcon,
};

/// 🔠🗨️, already in 🗄️ db text
String kAlreadyInDB = "already in the database";

/// 🔠, 📱 App Title
String kAppTitle = "PDFi";

/// 🧐 Checking for Update URL
String kCheckForUpdateURL = "https://skj-skj.github.io/check-for-update/pdfi.json";

/// ➕ Create Table Query
String kCreateTableQuery = '''
    CREATE TABLE $kDOCTableName (
	    filename TEXT PRIMARY KEY,
      path TEXT,
      thumb BLOB,
  	  docText TEXT,
  	  tags TEXT,
      hash TEXT,
      folder TEXT
    )
    ''';

/// 🔠 , 🗄️ Database is Empty Message
String kDatabaseEmptyText = "No Files Found, Click on + to import Documents";

/// 🔠, 🗄️ Database file Name
String kDBFileName = "data.db";

/// 🔠, 'doc_files' 📁 Directory name
String kDOCFilesPath = "doc_files";

/// 🔠, 🗄️ Database Table name
String kDOCTableName = "doc_table";

/// 🔠, 🌐 URI of 'file_error.png'
String kFileErrorImage = "assets/images/file_error.png";

/// Uint8List Representation of 'file_error.png' image
Uint8List kFileErrorUint8List = Uint8List.fromList([0]);

/// 🔠, 🙏 Give Permission Text
String kGivePermissionText = "Click Here to Give Permission";

/// 🔠🗨️, 🙏 Give Permission Text for 🔘 FAB
String kGivePermissionTextFAB = "Please Give Permission";

/// 🔠, ❔ Hint Text for Tags TextField in
String kHintText = "Ex: LED Bulb,Panel,Round";

/// 🔠🗨️, Imported Successfully Text
String kImportedSuccessfully = "Imported Successfully";

/// 🔠🗨️, Importing File Message shown in SnackBar
String kImportingFilesMessage = "Importing Files, Please Wait";

/// 💄 TextStyle for [Item]
TextStyle kItemWidgetTextStyle = TextStyle(fontSize: 12);

/// 🗺️ Map/json, when chec
Map kNullAppVersionJSON = {
        "version": "0.0.0",
        "url": "https://github.com/skj-skj/PDFi/releases"
      };

/// Null [DOCModel], when documents file is failed to saved in app 📁 directory this is used
DOCModel kNullDOCModel = DOCModel(
  path: 'null',
  docText: '',
  thumb: Uint8List(0),
  hash: '',
  folder: '',
  tags: '',
);

/// 🔠, [path] Asending for SQLite
String kPathAsc = "path ASC";

/// 🔠, [path] Desending for SQLite
String kPathDesc = "path DESC";

/// 🔠 , 🎲 PDF MimeType
String kPDFMimeType = 'application/pdf';

/// 🔠 , 🎲 Spread Sheet MimeType
List<String> kSpreadSheetMimeTypes = [
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
  'application/vnd.ms-excel',
  'application/vnd.ms-excel.sheet.macroEnabled.12'
];

/// 🔠, 🌐 URI of 'xlsx_icon_256.png'
String kXLSXFileIcon = "assets/images/xlsx_icon_256.png";

/// Uint8List Representation of 'xlsx_icon_256.png' image
Uint8List kXLSXUint8List = Uint8List.fromList([1]);

/// 🔠 ,🎲 Word Document MimeType
List<String> kWordDocumentMimeTypes = [
  'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
];

/// 🔠, 🌐 URI of 'docx_icon_256.png'
String kDOCXFileIcon = "assets/images/docx_icon_256.png";

/// Uint8List Representation of 'docx_icon_256.png' image
Uint8List kDOCXUint8List = Uint8List.fromList([2]);


/// Note for Uint8List Usage:
/// 0: File Error
/// 1: xlsx File
/// 2: docx File