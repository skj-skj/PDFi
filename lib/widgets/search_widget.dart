import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/pdfItemModel.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:pdf_indexing/functions/utils.dart' as Utils;

class SearchWidget extends StatelessWidget {
  // const SearchWidget({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextField(
        onChanged: (text) async {
          print(text);
          DBHelper dbHelper = DBHelper();
          // String storagePath = await Utils.getStoragePath();
          // Database db = await openDatabase(
          //   join(storagePath, kDBFileName),
          //   version: 1,
          // );
          List<Map> dbResultItems =
              await dbHelper.queryForFilePathsWithCondition(text);
          context.read<PdfItemModel>().updateItem(dbResultItems);
          // db.close();
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Search",
          hintText: "Enter Search Term",
        ),
      ),
    );
  }
}
