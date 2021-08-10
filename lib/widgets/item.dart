import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/widgets/popup_menu.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thumbnailer/thumbnailer.dart';

// ignore: must_be_immutable
class Item extends StatelessWidget {
  final path;
  bool fileExist = true;
  Item({required this.path});
  @override
  Widget build(BuildContext context) {
    isFileExist();
    double screenWidth = MediaQuery.of(context).size.width;
    double itemImageSize = screenWidth / 2.25;
    return Card(
      child: Container(
        width: itemImageSize,
        // height: itemImageSize + 60,
        child: Column(
          children: [
            Text(
              Utils.getFileNameFromPath(path),
              style: kItemWidgetTextStyle,
            ),
            InkWell(
              onTap: () {
                print("Image Pressed");
                OpenFile.open(path);
              },
              child: Thumbnail(
                key: fileExist ? Key(path) : Key(kFileNotFoundImage),
                mimeType: fileExist ? 'application/pdf' : 'image/png',
                widgetSize: itemImageSize - 25,
                dataResolver: () async {
                  //Check if file exists
                  if (fileExist) {
                    return File(path).readAsBytesSync();
                  } else {
                    //Return "No File Found by Andreas Wikström from the Noun Project" if File doesnot exist
                    return (await rootBundle.load(kFileNotFoundImage))
                        .buffer
                        .asUint8List();
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Menu Button
                popupMenu(context: context, path: path),
                //Share Button
                IconButton(
                  onPressed: () {
                    print("Share Pressed");
                    Share.shareFiles([path]);
                  },
                  icon: Icon(Icons.share),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void isFileExist() async {
    fileExist = await Utils.isFileExistInDir(path);
  }
}
