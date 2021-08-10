import 'package:flutter/material.dart';

String kCreateTableQuery = '''
    CREATE TABLE $kPdfTableName (
	    filename TEXT PRIMARY KEY,
      path TEXT,
  	  pdfText TEXT,
  	  tags TEXT,
      hash TEXT,
      folder TEXT
    )
    ''';
String kDatabaseEmptyText = "Database is Empty, Click on + to import PDF files";
String kDBFileName = "data.db";
String kFileNotFoundImage = "assets/images/no_file_found.png";
String kGivePermissionText = "Give Permission To Access Files";
TextStyle kItemWidgetTextStyle = TextStyle(fontSize: 12);
String kPathAsc = "path ASC";
String kPathDesc = "path DESC";
String kPdfFilesPath = "pdf_files";
String kPdfTableName = "pdf_table";
