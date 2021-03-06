// π― Dart imports:
import 'dart:typed_data';

// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π Project imports:
import 'package:pdf_indexing/model/doc_model.dart';

/// πΊοΈ<π‘,π >, Map of Image URI with their Documents Type
Map<String, String> assetMap = {
  'file_error': kFileErrorImage,
  'xlsx': kXLSXFileIcon,
};

/// π π¨οΈ, already in ποΈ db text
String kAlreadyInDB = "already in the database";

/// π , π± App Title
String kAppTitle = "PDFi";

/// π§ Checking for Update URL
String kCheckForUpdateURL = "https://skj-skj.github.io/check-for-update/pdfi.json";

/// β Create Table Query
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

/// π  , ποΈ Database is Empty Message
String kDatabaseEmptyText = "No Files Found, Click on + to import Documents";

/// π , ποΈ Database file Name
String kDBFileName = "data.db";

/// π , 'doc_files' π Directory name
String kDOCFilesPath = "doc_files";

/// π , ποΈ Database Table name
String kDOCTableName = "doc_table";

/// π , π URI of 'file_error.png'
String kFileErrorImage = "assets/images/file_error.png";

/// Uint8List Representation of 'file_error.png' image
Uint8List kFileErrorUint8List = Uint8List.fromList([0]);

/// π , π Give Permission Text
String kGivePermissionText = "Click Here to Give Permission";

/// π π¨οΈ, π Give Permission Text for π FAB
String kGivePermissionTextFAB = "Please Give Permission";

/// π , β Hint Text for Tags TextField in
String kHintText = "Ex: LED Bulb,Panel,Round";

/// π π¨οΈ, Imported Successfully Text
String kImportedSuccessfully = "Imported Successfully";

/// π π¨οΈ, Importing File Message shown in SnackBar
String kImportingFilesMessage = "Importing Files, Please Wait";

/// π TextStyle for [Item]
TextStyle kItemWidgetTextStyle = TextStyle(fontSize: 12);

/// πΊοΈ Map/json, when chec
Map kNullAppVersionJSON = {
        "version": "0.0.0",
        "url": "https://github.com/skj-skj/PDFi/releases"
      };

/// Null [DOCModel], when documents file is failed to saved in app π directory this is used
DOCModel kNullDOCModel = DOCModel(
  path: 'null',
  docText: '',
  thumb: Uint8List(0),
  hash: '',
  folder: '',
  tags: '',
);

/// π , [path] Asending for SQLite
String kPathAsc = "path ASC";

/// π , [path] Desending for SQLite
String kPathDesc = "path DESC";

/// π  , π² PDF MimeType
String kPDFMimeType = 'application/pdf';

/// π  , π² Spread Sheet MimeType
List<String> kSpreadSheetMimeTypes = [
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
  'application/vnd.ms-excel',
  'application/vnd.ms-excel.sheet.macroEnabled.12'
];

/// π , π URI of 'xlsx_icon_256.png'
String kXLSXFileIcon = "assets/images/xlsx_icon_256.png";

/// Uint8List Representation of 'xlsx_icon_256.png' image
Uint8List kXLSXUint8List = Uint8List.fromList([1]);

/// π  ,π² Word Document MimeType
List<String> kWordDocumentMimeTypes = [
  'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
];

/// π , π URI of 'docx_icon_256.png'
String kDOCXFileIcon = "assets/images/docx_icon_256.png";

/// Uint8List Representation of 'docx_icon_256.png' image
Uint8List kDOCXUint8List = Uint8List.fromList([2]);


/// Note for Uint8List Usage:
/// 0: File Error
/// 1: xlsx File
/// 2: docx File