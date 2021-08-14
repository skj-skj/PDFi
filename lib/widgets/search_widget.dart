// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/model/pdfItemModel.dart';

/// 💄 Search Widget
///
/// It is TextField Widget
///   * onChange 🌀 Update the [item] of pdfItemModel 🧰
class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextField(
        // controller: TextEditingController(text: ''),
        onChanged: (text) async {
          DBHelper dbHelper = DBHelper();

          if (text == '') {
            context
                .read<PDFItemModel>()
                .updateItem(await dbHelper.queryForAllfilePaths());
          }

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
