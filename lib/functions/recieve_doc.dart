// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/docUtils.dart' as DOCUtils;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/doc_item_model.dart';
import 'package:pdf_indexing/model/doc_model.dart';
import 'package:pdf_indexing/model/progress_model.dart';

// it recieve doc from other apps sharing intent
/// 📲 recieve dpc File
///
/// From Other Apps, Like:
///   - 🗃️ File Manager
///   - 📺 Social Media
///   - 🗯️ Messenger
///   - ☁️ Cloud Storage
///   - etc.
///
/// Requires, BuildContext [context], [_messengerKey], Function [updateIsImporting]
///
/// [updateIsImporting] is a callback to update the value of [isImporting] in the main.dart
void recieveDOC({
  required BuildContext context,
  required GlobalKey<ScaffoldMessengerState> key,
  required Function updateIsImporting,
}) async {
  Future.delayed(Duration(seconds: 1));

  // 🗄️ Database Helper
  DBHelper dbHelper = DBHelper();

  //List of Files [📄,] Shared by User
  List<SharedMediaFile> sharedFiles = [];

  // 📟 [countNewFiles] count new files which are imported
  // 📟 [countExistFiles] count already existing files in 📁 App Directory
  // 📟 [countUnsupportedFiles] count files which are not Documents
  // 📟 [countCorrupt] count corrupt files which user selected
  int countNewFiles = 0,
      countExistFiles = 0,
      countUnsupportedFiles = 0,
      countCorrupt = 0;

  try {
    // When 📱 App is 📪 Closed
    sharedFiles += await ReceiveSharingIntent.getInitialMedia();
    print("Shared 1");

    // When 📱 App is 📭 in Memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
      sharedFiles += files;
    });
  } catch (e) {
    print("Shared Error:");
    print(e);
    sharedFiles = [];
    countCorrupt++;
  }
  // 📝 Setting Default Value of Current & Total
  // For Progress
  context.read<ProgressModel>().setDefaultValue();

  // List of Filename in the 📁 App Directory
  List<String> docFileNameAlreadyInDir = (await Utils.getFilePathListFromDir())
      .map((path) => Utils.getFileNameFromPath(path))
      .toList();

  // 🗨️ SnackBar, if sharedFiles != []
  if (sharedFiles.length > 0) {
    // 📝 Setting isImporting to 1️⃣ true
    // Will show 🌀 CircularProgressIndicator() on FAB
    updateIsImporting(true);

    // 📝 Set Total Values = Total No of Files user Selected
    context.read<ProgressModel>().updateTotalValue(sharedFiles.length);

    // 🗨️ Showing File is Importing Message
    showSnackBar(context, kImportingFilesMessage, key);
  }

  for (SharedMediaFile sharedFile in sharedFiles) {
    // ➕ Updating the progress of Current Value by 1
    context.read<ProgressModel>().currentValueIncrement();

    // 📄 [docFile]
    File docFile = File(sharedFile.path);

    // 🤔 Checking [docFile] is of type Documents
    if (!Utils.isDOC(docFile.path)) {
      countUnsupportedFiles++;
      continue;
    }
    // 🤔 Checking if the [docFile] #️⃣ Already Exist in 🗄️ Database or not
    if (await Utils.isHashExists(docFile)) {
      countExistFiles++;
      continue;
    } else {
      // ⚙️ Generating [docModel] for [docFile]
      DOCModel docModel =
          await DOCUtils.getDOCModelOfFile(docFile, docFileNameAlreadyInDir);
      print(docModel.toString());
      if (docModel.path != 'null') {
        // 📥 Saving [docModel] in 🗄️ Database
        dbHelper.saveDOC(docModel);
        countNewFiles++;
      } else {
        countCorrupt++;
      }

      // ➕ Updating [item]
      context.read<DOCItemModel>().updateItem(await Utils.getDOCDataFromDB());
    }
  }

  // 📝 Setting isImporting to 1️⃣ true
  // Will show ➕ on FAB
  updateIsImporting(false);

  // 📝 Setting Default Value of Current & Total
  // For Progress
  context.read<ProgressModel>().setDefaultValue();

  // if sharedFiles != [], means user have shared some files
  if (sharedFiles.length > 0) {
    // 🔥 Deleting Cache
    Utils.deleteCache();

    // 🗨️, Files Imported Successfully SnackBar
    String text = Utils.getFileOrFilesText(
        countNewFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text $kImportedSuccessfully", key);
  }
  if (countExistFiles > 0) {
    // 🗨️, Files already in the 🗄️ Database SnackBar
    String text = Utils.getFileOrFilesText(
        countExistFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text $kAlreadyInDB", key);
  }
  if (countUnsupportedFiles > 0) {
    // 🗨️, Files are 🚫 Supported
    String text = Utils.getFileOrFilesText(
        countUnsupportedFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text are not Supported", key);
  }
  // if [countCorrupt] > 0
  // means some files which user selected are corrupt
  if (countCorrupt > 0) {
    // 🗨️, Files is Corrupt in the 🗄️ Database SnackBar
    String text = Utils.getFileOrFilesText(countExistFiles);
    showSnackBar(context, "$text are Corrupt", key);
  }
}
