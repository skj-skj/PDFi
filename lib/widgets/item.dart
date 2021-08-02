import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thumbnailer/thumbnailer.dart';
import 'package:provider/provider.dart';

class Item extends StatelessWidget {
  // const Item({ Key? key }) : super(key: key);
  Item({required this.path});
  final path;
  @override
  Widget build(BuildContext context) {
    double itemImageSize = (MediaQuery.of(context).size.width) / 2 - 25;
    return Card(
      child: Container(
        width: itemImageSize,
        height: itemImageSize + 60,
        child: Column(
          children: [
            Text(
              Utils.getFileNameFromPath(path),
              style: kItemWidgetTextStyle,
            ),
            InkWell(
              onTap: () {
                // DBHelper dbH = DBHelper();
                // dbH.deleteFromFilename('Ziva New MRPspdf');
                print("Image Pressed");
                OpenFile.open(path);
              },
              child: Thumbnail(
                key: Key(path),
                mimeType: 'application/pdf',
                widgetSize: itemImageSize - 25,
                dataResolver: () async {
                  //Check if file exists
                  if (await Utils.isFileExistInDir(path)) {
                    return File(path).readAsBytesSync();
                  } else {
                    //Return "No File Found by Andreas Wikström from the Noun Project" if File doesnot exist
                    return (await rootBundle.load('assets/no_file_found.png'))
                        .buffer
                        .asUint8List();
                  }
                },
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    print("Edit Pressed");
                                    DBHelper dbH = DBHelper();
                dbH.deleteFromPath(path);
                Utils.deleteFromDir(path);
                context.read<PdfItemModel>().deleteItems(path);
                  },
                  child: Text("Menu"),
                ),
                TextButton(
                  onPressed: () {
                    print("Share Pressed");
                    Share.shareFiles([path]);
                  },
                  child: Text("Share"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}