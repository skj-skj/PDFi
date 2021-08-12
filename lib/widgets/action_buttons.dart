// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfItemModel.dart';

/// [💄]
///
/// Return [Widget,]
/// Returns Action Buttons, which displayed on Appbar
List<Widget> actionButtons({required BuildContext context}) {
  /// 🔘 Refresh Button
  ///
  /// Refresh items List
  IconButton refresh = IconButton(
    onPressed: () async {
      context
          .read<PDFItemModel>()
          .updateItemFromList(await Utils.getFilePathListFromDB());
    },
    icon: Icon(Icons.refresh),
  );

  /// 🔘 Delete Button
  ///
  /// Deleted Cache Files
  // ignore: unused_local_variable
  IconButton delete = IconButton(
    onPressed: () {
      Utils.deleteCache();
    },
    icon: Icon(Icons.delete),
  );

  /// [🔘] Action Button List
  return [
    refresh,
    // delete,
  ];
}
