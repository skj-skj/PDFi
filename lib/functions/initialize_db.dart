// import 'dart:io';
import 'package:pdf_indexing/functions/db_helper.dart';
// import 'package:pdf_indexing/functions/request_permission.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/pdfItemModel.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:pdf_indexing/functions/utils.dart' as Utils;

void initialPDFItem({required BuildContext context}) async {
  // await requestPermission();

  // String storagePath = await Utils.getStoragePath();
  // Database db = await openDatabase(join(storagePath,kDBFileName),version: 1);
  // Database db = await openDatabase(
  //   join(storagePath, kDBFileName),
  //   version: 1,
  //   onCreate: (Database db, int version) async {
  //     await db.execute('''
  //   CREATE TABLE $kPdfTableName (
  //     filename TEXT PRIMARY KEY,
  //     path TEXT,
  // 	  pdfText TEXT,
  // 	  keywords TEXT
  //   )
  //   ''');
  //   },
  // );

  // Directory pdfFilesDir = Directory(join(storagePath, kPdfFilesPath));
  // if (!pdfFilesDir.existsSync()) {
  //   await pdfFilesDir.create(recursive: true);
  // }

  List<Map> dbResultItems = [];
  try {
    DBHelper dbHelper = DBHelper();
    dbResultItems = await dbHelper.queryForAllfilePaths();
  } catch (e) {
    print(e);
  }

  context.read<PdfItemModel>().updateItem(dbResultItems);

  // db.close();
}
