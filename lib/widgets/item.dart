// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/widgets/popup_menu.dart';
import 'package:pdf_indexing/widgets/thumbnail.dart';

/// 💄 Item Widget
// ignore: must_be_immutable
class Item extends StatelessWidget {
  final path;
  final thumb;
  bool fileExist = true;
  Item({
    required this.path,
    required this.thumb,
  });
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
            /// 🔤 Title 💄
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Utils.getFileNameFromPath(path),
                style: kItemWidgetTextStyle,
                textAlign: TextAlign.center,
              ),
            ),

            /// 🖼️ Thumbnail 💄
            InkWell(
              onTap: () {
                if (fileExist) {
                  // Open File
                  OpenFile.open(path);
                } else {
                  SnackBar snackBar =
                      SnackBar(content: Text("Oops! File Not Found"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },

              /// 🖼️ Thumbnail of the Documents
              child: Thumbnail(
                path: path,
                thumb: thumb,
                itemImageSize: itemImageSize,
              ),
            ),

            /// Popup Menu & Share Icons 💄
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔘 Menu Button
                popupMenu(context: context, path: path),
                // 🔘 Share Button
                IconButton(
                  onPressed: () {
                    // Share File
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

  /// 📝 Set fileExist
  ///
  /// 🤔 Checking if the fileExist in the App Directory or not
  void isFileExist() async {
    fileExist = await Utils.isFileExistInDir(path);
  }
}
