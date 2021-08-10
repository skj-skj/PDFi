import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextField(
        onChanged: (text) async {
          print(text);
          DBHelper dbHelper = DBHelper();

          List<Map> dbResultItems =
              await dbHelper.queryForFilePathsWithCondition(text);
          context.read<PDFItemModel>().updateItem(dbResultItems);
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
