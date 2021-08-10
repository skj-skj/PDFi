import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:provider/provider.dart';

//not in use currrently
void initialPDFItem({required BuildContext context}) async {
  List<Map> dbResultItems = [];
  try {
    DBHelper dbHelper = DBHelper();
    dbResultItems = await dbHelper.queryForAllfilePaths();
  } catch (e) {
    print(e);
  }

  context.read<PDFItemModel>().updateItem(dbResultItems);
}
