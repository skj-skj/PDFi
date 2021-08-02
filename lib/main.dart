import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;

import 'package:pdf_indexing/pdfItemModel.dart';
import 'package:pdf_indexing/pdfModel.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:sqflite/sqflite.dart';
import 'constants.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
// import 'functions/initialize_db.dart';
import 'package:pdf_indexing/functions/request_permission.dart' as reqP;
// import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PdfItemModel(),
      child: Home(),
    ),
  );
}

void receiveSharingIntent() async {
  DBHelper dbHelper = DBHelper();
  //List of Files Shared
  List<SharedMediaFile> sharedFiles = [];
  // When App is Closed
  sharedFiles += await ReceiveSharingIntent.getInitialMedia();
  // When App is in Memory
  ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
    sharedFiles += files;
  });

  // Database Open
  String storagePath = await Utils.getStoragePath();
  // Database db = await openDatabase(
  //   join(storagePath, kDBFileName),
  //   version: 1,
  // );

  // Copying File to Storage and then indexing to db
  for (SharedMediaFile sharedFile in sharedFiles) {
    // Extract the file name
    String filename = Utils.getFileNameFromPath(sharedFile.path);
    // Saving File to Storage
    File pdfSavedFile = await File(sharedFile.path)
        .copy(join(storagePath, kPdfFilesPath, filename));

    //Extracting Text from the pdf
    PDFDoc doc = await PDFDoc.fromFile(pdfSavedFile);
    PDFPage page = doc.pageAt(1);
    String pageText = await page.text;

    // Generating SHA1 Hash
    String hash = await Utils.getSHA1Hash(pdfSavedFile);

    // Creating pdfModel Object containg path,pageText and keywords
    PDFModel pdfModel = PDFModel(
        path: pdfSavedFile.path, pdfText: pageText, keywords: '', hash: hash);

    //Save to Database
    // db.insert(kPdfTableName, pdfModel.toMap());
    dbHelper.savePdf(pdfModel);
  }
  //Cloase Database
  // db.close();
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

  @override
  void initState() {
    super.initState();
    Utils.createFolderIfNotExist();
    // Utils.createDBIfNotExist();
    // setFilePathsFromDB();
    setstoragePermissionStatus();
    setDBIsEmpty();
  }

  void showSnackBar(BuildContext context, String text,
      GlobalKey<ScaffoldMessengerState> key) {
    key.currentState!.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    // initialPDFItem(context: context);
    receiveSharingIntent();
    return MaterialApp(
      //For SnackBar
      scaffoldMessengerKey: _messangerKey,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("PDF Indexing"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SearchWidget(),
                (storagePermissionStatus)
                    ? (!dbIsEmpty)
                        ? Consumer<PdfItemModel>(
                            builder: (context, pdfItem, child) {
                              // context.read<PdfItemModel>().updateItemFromList(filePathsFromDB);
                              return Wrap(
                                  children: context.read<PdfItemModel>().items);
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
              String snackBarMsg;
              if (storagePermissionStatus) {
                print("Import Pressed");

                List<String> pdfFileNameAlreadyInDir =
                    (await Utils.getFilePathListFromDir())
                        .map((path) => Utils.getFileNameFromPath(path))
                        .toList();

                DBHelper dbHelper = DBHelper();
                int countFiles = 0;
                int alreadyExistsFiles = 0;
                String alreadyExistsText = "";
                int totalPDFFiles = 0;

                List<File>? pdfFiles = await PdfUtils.pickPDFFiles();
                if (pdfFiles != null) {
                  totalPDFFiles = pdfFiles.length;
                  for (File pdfFile in pdfFiles) {
                    // Checking if the file exists or not
                    if(await Utils.isHashExists(pdfFile)){
                      print("Already Exists");
                      alreadyExistsFiles += 1;
                      alreadyExistsText = ", File Already Exist";
                      continue;
                    }else{
                      PDFModel pdfModel =
                          await PdfUtils.getPdfModelOfFile(pdfFile,pdfFileNameAlreadyInDir);
                      dbHelper.savePdf(pdfModel);
                      print(pdfModel.toString());
                      countFiles += 1;
                    }
                    
                     
                  }
                }

                //alreadyExistsText: if some file are already exists
                if (alreadyExistsFiles != totalPDFFiles) {
                  alreadyExistsText = ", Some Files Already Exists";
                }
                context
                    .read<PdfItemModel>()
                    .updateItemFromList(await Utils.getFilePathListFromDB());

                if (countFiles > 0 && dbIsEmpty) {
                  setState(() {
                    dbIsEmpty = false;
                  });
                }
                snackBarMsg =
                    "${Utils.getFileOrFilesText(countFiles)} Imported $alreadyExistsText";
              } else {
                snackBarMsg = "Please Give Storage Access Permission";
              }
              FilePicker.platform.clearTemporaryFiles();
              // Fluttertoast.showToast(msg: snackBarMsg);
              showSnackBar(context, snackBarMsg, _messangerKey);
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
