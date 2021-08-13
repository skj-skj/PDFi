// 🐦 Flutter imports:
import 'package:flutter/material.dart';

/// 🔠🗨️, already in 🗄️ db text
String kAlreadyInDB = "already in the database";

///🔠, 📱 App Title
String kAppTitle = "PDF Indexing";

/// ➕ Create Table Query
String kCreateTableQuery = '''
    CREATE TABLE $kPdfTableName (
	    filename TEXT PRIMARY KEY,
      path TEXT,
      thumb BLOB,
  	  pdfText TEXT,
  	  tags TEXT,
      hash TEXT,
      folder TEXT
    )
    ''';

/// 🔠, 🗄️ Database is Empty Message
String kDatabaseEmptyText = "Database is Empty, Click on + to import PDF files";

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

/// 🔠, [path] Asending for SQLite
String kPathAsc = "path ASC";

/// 🔠, [path] Desending for SQLite
String kPathDesc = "path DESC";

/// 🔠, 'pdf_files' 📁 Directory name
String kPdfFilesPath = "pdf_files";

/// 🔠, 🗄️ Database Table name
String kPdfTableName = "pdf_table";
