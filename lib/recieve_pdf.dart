import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:pdf_indexing/pdfModel.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// it recieve pdf from other apps sharing intent
void recievePDF({
  required BuildContext context,
  required GlobalKey<ScaffoldMessengerState> key,
}) async {
  print("reverse Share start");
  DBHelper dbHelper = DBHelper();
  //List of Files Shared
  List<SharedMediaFile> sharedFiles = [];
  int countNewFiles = 0, countExistFiles = 0, countNotPdfFiles = 0;

  // When App is Closed
  sharedFiles += await ReceiveSharingIntent.getInitialMedia();
  // When App is in Memory
  ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
    sharedFiles += files;
  });

  // print("reverse Share mid");

  List<String> pdfFileNameAlreadyInDir = (await Utils.getFilePathListFromDir())
      .map((path) => Utils.getFileNameFromPath(path))
      .toList();
  // Copying File to Storage and then indexing to db
  if (sharedFiles.length > 0) {
    showSnackBar(context, "Files Importing, Please Wait", key);
  }

  for (SharedMediaFile sharedFile in sharedFiles) {
    print("Reverse Shared File: ${sharedFile.path}");
    File pdfFile = File(sharedFile.path);
    //Checking the file is pdf or not
    if (!Utils.isPDF(pdfFile.path)) {
      countNotPdfFiles++;
      continue;
    }
    //Checking is the file already exists in the database
    if (await Utils.isHashExists(pdfFile)) {
      print("Already Exists");
      countExistFiles++;

      continue;
    } else {
      PDFModel pdfModel =
          await PdfUtils.getPdfModelOfFile(pdfFile, pdfFileNameAlreadyInDir);
      try {
        dbHelper.savePdf(pdfModel);
        countNewFiles++;
      } catch (e) {
        print(e);
        print("looks like pdf is already stored in the DB");
        continue;
      }

      print(pdfModel.toString());
    }
  }

  context
      .read<PDFItemModel>()
      .updateItemFromList(await Utils.getFilePathListFromDB());
  if (sharedFiles.length > 0) {
    String text = Utils.getFileOrFilesText(
        countNewFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text Imported Successfully", key);
  }
  if (countExistFiles > 0) {
    String text = Utils.getFileOrFilesText(
        countExistFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text already in the database", key);
  }
  if (countNotPdfFiles > 0) {
    String text = Utils.getFileOrFilesText(
        countNotPdfFiles); // No File , 1 File, 2 Files, 3 Files etc.
    showSnackBar(context, "$text are not PDF", key);
  }

  print("reverse Share end");
}
