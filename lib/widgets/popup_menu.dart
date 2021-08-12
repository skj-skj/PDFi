// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfItemModel.dart';

/// 💄🔘 Cancel Button
TextButton cancelButton({required BuildContext context}) {
  return TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Text("CANCEL"),
  );
}

/// 🗑️ Delete File from 🗄️ Database & 📁 Directory
void deleteButtonOnYes({
  required BuildContext context,
  required String path,
  required DBHelper dbHelper,
}) {
  dbHelper.deleteFromPath(path);
  Utils.deleteFromDir(path);
  context.read<PDFItemModel>().deleteItems(path);
  Navigator.pop(context);
}

/// 🔠🗞️ Return [tags] data from the [path]
Future<String> getOldTags({
  required String path,
  required DBHelper dbHelper,
}) async {
  return await dbHelper.getTags(path: path);
}

/// 🎛️ Return TextEditingController or null,
///
/// According to [oldTags]
///   * Empty => null
///   * Some Value => TextEditingController with Initial Value
getTextController({
  required String oldTags,
}) {
  return (oldTags != '')
      ? TextEditingController(
          text: oldTags,
        )
      : null;
}

/// 💄 Popup Context Menu Method
PopupMenuButton<int> popupMenu(
    {required BuildContext context, required String path}) {
  /// [💄], List of Menu Item
  List<PopupMenuItem<int>> menu = [
    PopupMenuItem(
      value: 1,
      child: Text("Tags"),
    ),
    PopupMenuItem(
      value: 2,
      child: Text("Delete"),
    ),
  ];

  return PopupMenuButton(
    itemBuilder: (context) => menu,
    onSelected: (value) async {
      DBHelper dbH = DBHelper();

      if (value == 1) {
        String oldTags = await getOldTags(path: path, dbHelper: dbH);
        String tagsText = "";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () => Future.value(false),
                child: AlertDialog(
                  title: Text("Tags:"),
                  content: TextField(
                    controller: getTextController(oldTags: oldTags),
                    decoration: InputDecoration(
                      hintText: kHintText,
                    ),
                    onChanged: (text) {
                      tagsText = text;
                    },
                  ),
                  actions: [
                    cancelButton(context: context),
                    TextButton(
                      onPressed: () {
                        // 📥 Updating [tags] in 🗄️ Database, Where path = [path]
                        dbH.saveTags(path: path, tags: tagsText);
                        Navigator.pop(context);
                      },
                      child: Text("SAVE"),
                    ),
                  ],
                ),
              );
            });
      } else if (value == 2) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Are You Want to Delete?"),
                content: Text(Utils.getFileNameFromPath(path)),
                actions: [
                  cancelButton(context: context),
                  TextButton(
                    onPressed: () {
                      deleteButtonOnYes(
                          context: context, path: path, dbHelper: dbH);
                    },
                    child: Text("YES"),
                  )
                ],
              );
            });
      }
    },
  );
}
