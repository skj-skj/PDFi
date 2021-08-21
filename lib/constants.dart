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

/// 🔠, 🌐 URL of 'no_file_found.png'
String kFileNotFoundImage = "assets/images/no_file_found.png";

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
