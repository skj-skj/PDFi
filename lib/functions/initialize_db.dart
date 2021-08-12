// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/model/pdfItemModel.dart';

//not in use currrently
/// To Initialise pdf Items in Provider
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
