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
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfItemModel.dart';
import 'package:pdf_indexing/model/pdfModel.dart';

// it recieve pdf from other apps sharing intent
/// 📲 recieve pdf File
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
void recievePDF({
  required BuildContext context,
  required GlobalKey<ScaffoldMessengerState> key,
  required Function updateIsImporting,
}) async {
  // 🗄️ Database Helper
  DBHelper dbHelper = DBHelper();

  //List of Files [📄,] Shared by User
  List<SharedMediaFile> sharedFiles = [];

  // 📟 [countNewFiles] count new files which are imported
  // 📟 [countExistFiles] count already existing files in 📁 App Directory
  // 📟 [countNotPDFfiles] count files which are not pdf
  int countNewFiles = 0, countExistFiles = 0, countNotPDFfiles = 0;

  // When 📱 App is 📪 Closed
  sharedFiles += await ReceiveSharingIntent.getInitialMedia();

  // When 📱 App is 📭 in Memory
  ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
    sharedFiles += files;
  });

  // List of Filename in the 📁 App Directory
  List<String> pdfFileNameAlreadyInDir = (await Utils.getFilePathListFromDir())
      .map((path) => Utils.getFileNameFromPath(path))
      .toList();

  // 🗨️ SnackBar, if sharedFiles != []
  if (sharedFiles.length > 0) {
    // 📝 Setting isImporting to 1️⃣ true
    // Will show 🌀 CircularProgressIndicator() on FAB
    updateIsImporting(true);
    showSnackBar(context, kImportingFilesMessage, key);
  }

  for (SharedMediaFile sharedFile in sharedFiles) {
    // 📄 [pdfFile]
    File pdfFile = File(sharedFile.path);

    // 🤔 Checking [pdfFile] have .pdf extension
    if (!Utils.isPDF(pdfFile.path)) {
      countNotPDFfiles++;
      continue;
    }
    // 🤔 Checking if the [pdfFile] #️⃣ Already Exist in 🗄️ Database or not
    if (await Utils.isHashExists(pdfFile)) {
      print("Already Exists");
      countExistFiles++;
      continue;
    } else {
      // ⚙️ Generating [pdfModel] for [pdfFile]
      PDFModel pdfModel =
          await PdfUtils.getPdfModelOfFile(pdfFile, pdfFileNameAlreadyInDir);
      // ⛔ Handing Error
      try {
        // 📥 Saving [pdfModel] in 🗄️ Database
        dbHelper.savePdf(pdfModel);
        countNewFiles++;

        // ➕ Updating [item]
        context.read<PDFItemModel>().updateItem(await Utils.getPDFDataFromDB());
      } catch (e) {
        print(e);
        print("looks like pdf is already stored in the DB");
        continue;
      }
    }
  }

  // if sharedFiles != [], means user have shared some files
  if (sharedFiles.length > 0) {
    // 📝 Setting isImporting to 1️⃣ true
    // Will show ➕ on FAB
    updateIsImporting(false);

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
  if (countNotPDFfiles > 0) {
    // 🗨️, Files are 🚫 pdf
    String text = Utils.getFileOrFilesText(
        countNotPDFfiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text are not PDF", key);
  }
}
