import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;
import 'package:pdf_indexing/functions/request_permission.dart' as reqP;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:pdf_indexing/pdfModel.dart';
import 'package:pdf_indexing/recieve_pdf.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PDFItemModel(),
      child: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool storagePermissionStatus = false;
  bool dbIsEmpty = true;
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //For SnackBar
      scaffoldMessengerKey: _messangerKey,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("PDF Indexing"),
            actions: [
              //Refresh Button
              IconButton(
                  onPressed: () async {
                    context.read<PDFItemModel>().updateItemFromList(
                        await Utils.getFilePathListFromDB());
                  },
                  icon: Icon(Icons.refresh))
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SearchWidget(),
                (storagePermissionStatus)
                    ? (!dbIsEmpty)
                        ? Consumer<PDFItemModel>(
                            builder: (context, pdfItem, child) {
                              return Wrap(
                                children: context.read<PDFItemModel>().items,
                              );
                            },
                          )
                        : Center(
                            child: Text(kDatabaseEmptyText),
                          )
                    : Center(
                        child: TextButton(
                          onPressed: () async {
                            bool permissionStatus =
                                await reqP.requestStoragePermission();
                            setState(() {
                              storagePermissionStatus = permissionStatus;
                            });
                          },
                          child: Text(kGivePermissionText),
                        ),
                      )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // String snackBarMsg;
              if (storagePermissionStatus) {
                print("Import Pressed");

                List<String> pdfFileNameAlreadyInDir =
                    (await Utils.getFilePathListFromDir())
                        .map((path) => Utils.getFileNameFromPath(path))
                        .toList();

                DBHelper dbHelper = DBHelper();
                int countNewFiles = 0, countExistFiles = 0;

                List<File>? pdfFiles = await PdfUtils.pickPDFFiles();

                if (pdfFiles != null) {
                  showSnackBar(
                      context, "Importing Files, Please Wait", _messangerKey);

                  for (File pdfFile in pdfFiles) {
                    // Checking if the file exists or not
                    if (await Utils.isHashExists(pdfFile)) {
                      print("Already Exists");
                      countExistFiles++;
                      continue;
                    } else {
                      PDFModel pdfModel = await PdfUtils.getPdfModelOfFile(
                          pdfFile, pdfFileNameAlreadyInDir);
                      dbHelper.savePdf(pdfModel);
                      print(pdfModel.toString());
                      countNewFiles++;
                    }
                  }
                }

                context
                    .read<PDFItemModel>()
                    .updateItemFromList(await Utils.getFilePathListFromDB());
                // File Imported Successfully
                if (countNewFiles > 0) {
                  // File Importd When Database is empty
                  if (dbIsEmpty) {
                    setState(() {
                      dbIsEmpty = false;
                    });
                  }
                  String text = Utils.getFileOrFilesText(countNewFiles);
                  showSnackBar(
                      context, "$text Imported Successfully", _messangerKey);
                }
                // Files already exists in the database
                if (countExistFiles > 0) {
                  String text = Utils.getFileOrFilesText(countExistFiles);
                  showSnackBar(
                      context, "$text already in the database", _messangerKey);
                }
              } else {
                String text = "Please Give Storage Access Permission";
                showSnackBar(context, "$text", _messangerKey);
              }
              FilePicker.platform.clearTemporaryFiles();
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Utils.createFolderIfNotExist();
    setstoragePermissionStatus();
    setDBIsEmpty();
    recievePDF(context: context, key: _messangerKey);
  }

  void setDBIsEmpty() async {
    print("Before $dbIsEmpty");
    List<String> filePathFromDB = await Utils.getFilePathListFromDB();
    if (filePathFromDB.length > 0) {
      setState(() {
        dbIsEmpty = false;
      });
      print("After $dbIsEmpty");
    }
  }

  void setstoragePermissionStatus() async {
    storagePermissionStatus = await reqP.getStoragePermissionStatus();
  }
}
