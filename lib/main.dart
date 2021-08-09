import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;

import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:pdf_indexing/pdfModel.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';
// import 'package:pdf_text/pdf_text.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:sqflite/sqflite.dart';
import 'constants.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
// import 'functions/initialize_db.dart';
import 'package:pdf_indexing/functions/request_permission.dart' as reqP;
// import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PDFItemModel(),
      child: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  // const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool storagePermissionStatus = false;
  bool dbIsEmpty = true;
  // List<String> filePathsFromDB = [];
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  //For Snackbar
  // final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // void setFilePathsFromDB() async {
  //   filePathsFromDB = await Utils.getFilePathListFromDB();
  // }

  void setstoragePermissionStatus() async {
    storagePermissionStatus = await reqP.getStoragePermissionStatus();
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

  // void updateItemList({required BuildContext context}) async {
  //   context
  //       .read<PdfItemModel>()
  //       .updateItemFromList(await Utils.getFilePathListFromDB());
  // }

  void receiveSharingIntent() async {
    print("reverse Share start");
    DBHelper dbHelper = DBHelper();
    List<SharedMediaFile> sharedFiles = [];
    int countNewFiles = 0, countExistFiles = 0, countNotPdfFiles = 0;
    //List of Files Shared
    // List<SharedMediaFile> sharedFiles = [];
    // When App is Closed
    sharedFiles += await ReceiveSharingIntent.getInitialMedia();
    // When App is in Memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
      sharedFiles += files;
    });

    print("reverse Share mid");

    // Database Open
    // String storagePath = await Utils.getStoragePath();
    // Database db = await openDatabase(
    //   join(storagePath, kDBFileName),
    //   version: 1,
    // );
    List<String> pdfFileNameAlreadyInDir =
        (await Utils.getFilePathListFromDir())
            .map((path) => Utils.getFileNameFromPath(path))
            .toList();
    // Copying File to Storage and then indexing to db
    if (sharedFiles.length > 0) {
      showSnackBar(
          context, "Files Importing Files, Please Wait", _messangerKey);
    }

    for (SharedMediaFile sharedFile in sharedFiles) {
      print("Reverse Shared File: ${sharedFile.path}");
      File pdfFile = File(sharedFile.path);
      //Checking the file is pdf or not
      if (Utils.isPDF(pdfFile.path)) {
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
      showSnackBar(context, "$text Imported Successfully", _messangerKey);
    }
    if (countExistFiles > 0) {
      String text = Utils.getFileOrFilesText(
          countExistFiles); // No File , 1 File, 2 Files, 3 Files etc.
      showSnackBar(context, "$text already in the database", _messangerKey);
    }
    if (countNotPdfFiles > 0) {
      String text = Utils.getFileOrFilesText(
          countNotPdfFiles); // No File , 1 File, 2 Files, 3 Files etc.
      showSnackBar(context, "$text are not PDF", _messangerKey);
    }

    print("reverse Share end");
  }

  void showSnackBar(BuildContext context, String text,
      GlobalKey<ScaffoldMessengerState> key) {
    key.currentState!.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() {
    super.initState();
    Utils.createFolderIfNotExist();
    // Utils.createDBIfNotExist();
    // setFilePathsFromDB();
    setstoragePermissionStatus();
    setDBIsEmpty();
    receiveSharingIntent();
  }

  @override
  Widget build(BuildContext context) {
    // initialPDFItem(context: context);
    // updateItemList(context: context);
    return MaterialApp(
      //For SnackBar
      scaffoldMessengerKey: _messangerKey,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("PDF Indexing"),
            actions: [
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
                // Text(sharedFiles.toString()),
                SearchWidget(),
                (storagePermissionStatus)
                    ? (!dbIsEmpty)
                        ? Consumer<PDFItemModel>(
                            builder: (context, pdfItem, child) {
                              // context.read<PdfItemModel>().updateItemFromList(filePathsFromDB);
                              return Wrap(
                                  children: context.read<PDFItemModel>().items);
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

                // int countFiles = 0;
                // int alreadyExistsFiles = 0;
                // String alreadyExistsText = "";
                // int totalPDFFiles = 0;

                List<File>? pdfFiles = await PdfUtils.pickPDFFiles();

                if (pdfFiles != null) {
                  showSnackBar(context, "Files Importing Files, Please Wait",
                      _messangerKey);

                  // totalPDFFiles = pdfFiles.length;
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
                      // countFiles += 1;
                      countNewFiles++;
                    }
                  }
                }

                //alreadyExistsText: if some file are already exists
                // if (alreadyExistsFiles != totalPDFFiles) {
                //   alreadyExistsText = ", Some Files Already Exists";
                // }
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

                // snackBarMsg =
                //     "${Utils.getFileOrFilesText(countFiles)} Imported $alreadyExistsText";
              } else {
                String text = "Please Give Storage Access Permission";
                showSnackBar(context, "$text", _messangerKey);
              }
              FilePicker.platform.clearTemporaryFiles();
              // Fluttertoast.showToast(msg: snackBarMsg);
              // showSnackBar(context, snackBarMsg, _messangerKey);
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
