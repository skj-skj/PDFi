// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/model/doc_model.dart';

/// 🔠🗨️, already in 🗄️ db text
String kAlreadyInDB = "already in the database";

///🔠, 📱 App Title
String kAppTitle = "PDFi";

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

/// 🔠 , 🎲 PDF MimeType
String kPDFMimeType = 'application/pdf';

/// 🔠 , 🎲 Spread Sheet MimeType
List<String> kSpreadSheetTypes = [
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
  'application/vnd.ms-excel',
  'application/vnd.ms-excel.sheet.macroEnabled.12'
];

/// 🔠, 🗄️ Database file Name
String kDBFileName = "data.db";

/// 🔠, 🌐 URI of 'file_error.png'
String kFileErrorImage = "assets/images/file_error.png";

/// 🔠, 🌐 URI of 'xlsx_icon.png'
String kXLSXFileIcon = "assets/images/xlsx_icon.png";

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

/// 🔠, 'doc_files' 📁 Directory name
String kDOCFilesPath = "doc_files";

/// 🔠, 🗄️ Database Table name
String kDOCTableName = "doc_table";

/// 🗺️, Map of Image URI with their Documents Type
Map<String, String> assetMap = {
  'file_error': kFileErrorImage,
  'xlsx': kXLSXFileIcon,
};

/// Uint8List Representation of 'file_error.png' image
Uint8List kFileErrorUint8List = Uint8List.fromList([0]);

/// Uint8List Representation of 'xlsx_icon.png' image
Uint8List kXLSXUint8List = Uint8List.fromList([1]);
