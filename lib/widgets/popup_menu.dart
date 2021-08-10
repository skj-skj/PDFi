import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:provider/provider.dart';

PopupMenuButton<int> popupMenu(
    {required BuildContext context, required String path}) {
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
      if (value == 1) {
        DBHelper dbH = DBHelper();
        String oldTags = await dbH.getTags(path: path);
        String tagsText = "";
        print("clicked Tag");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () => Future.value(false),
                child: AlertDialog(
                  title: Text("Tags:"),
                  content: TextField(
                    controller: (oldTags != '')
                        ? TextEditingController(
                            text: oldTags,
                          )
                        : null,
                    decoration: InputDecoration(
                      hintText: "Ex: LED Bulb,Panel,Round",
                    ),
                    onChanged: (text) {
                      //  print(keywordText);
                      tagsText = text;
                      print(tagsText);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () {
                        print(tagsText);
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
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () {
                      DBHelper dbH = DBHelper();
                      dbH.deleteFromPath(path);
                      Utils.deleteFromDir(path);
                      context.read<PDFItemModel>().deleteItems(path);
                      Navigator.pop(context);
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
