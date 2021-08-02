import 'package:flutter/material.dart';

String kDBFileName = "data.db";
String kPdfTableName = "pdf_table";
String kPdfFilesPath = "pdf_files";
String kPathAsc = "path ASC";
String kPathDesc = "path DESC";
String kCreateTableQuery = '''
    CREATE TABLE $kPdfTableName (
	    filename TEXT PRIMARY KEY,
      path TEXT,
  	  pdfText TEXT,
  	  keywords TEXT,
      hash TEXT
    )
    ''';
TextStyle kItemWidgetTextStyle = TextStyle(fontSize: 12);
String kDatabaseEmptyText = "Database is Empty, Click on + to import PDF files";
String kGivePermissionText = "Give Permission To Access Files";
