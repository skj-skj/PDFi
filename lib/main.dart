// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/db_helper.dart';
import 'package:pdf_indexing/functions/pdfUtils.dart' as PdfUtils;
import 'package:pdf_indexing/functions/recieve_pdf.dart';
import 'package:pdf_indexing/functions/request_permission.dart' as reqP;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfItemModel.dart';
import 'package:pdf_indexing/model/pdfModel.dart';
import 'package:pdf_indexing/widgets/action_buttons.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';

//  Package imports:

//  Package imports:

void main() {
  runApp(
    /// ✅ Implementation of Provider State Management
    ChangeNotifierProvider(
      create: (context) => PDFItemModel(),
      child: Home(),
    ),
  );
}

/// 🧰💄 [Home] [StatefulWidget]
///
/// Displays Main Layout of the App
///   - Column[
///     SearchWidget,
///     Wrap(items)
///     ]
///   - 🔘 Floating Action Button
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// ⏲️ Current Back Press Time
  ///
  /// During initialization
  ///   - [currBackPressTime] = null
  ///
  /// When 🔙 Back Pressed its value will change
  DateTime? currBackPressTime;

  /// 🙏 Bool
  ///
  /// Storage Permission Status
  ///   - true = Granted
  ///   - false = Denied
  ///
  /// set to false at first
  bool storagePermissionStatus = false;

  /// is 🗄️ Database Empty
  ///
  ///   - true = yes (No Data)
  ///   - false = no (Some Data)
  bool dbIsEmpty = true;

  /// is App is currently importing pdf
  ///
  ///   - true = show 🌀 CircularProgressIndicator() on FAB
  ///   - false = show ➕ on FAB
  bool isImporting = false;

  /// 🗨️🔑 [_messengerKey] for SnackBar
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // For SnackBar
      scaffoldMessengerKey: _messengerKey,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(kAppTitle),
            actions: actionButtons(context: context),
          ),
          body: WillPopScope(
            // 🤝 Handle 🔙🔙 Double Back to Exit
            onWillPop: onWillPop,
            child: SingleChildScrollView(
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
                        ),
                  SizedBox(
                    height: 60,
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // 🤔 Checking if Storage permission given or not
              if (storagePermissionStatus) {
                // 🤔 Checking if Currently App is Imporing pdf files or not
                if (!isImporting) {
                  // List of Filename in the 📁 App Directory
                  List<String> pdfFileNameAlreadyInDir =
                      (await Utils.getFilePathListFromDir())
                          .map((path) => Utils.getFileNameFromPath(path))
                          .toList();

                  // 🗄️ Database Helper
                  DBHelper dbHelper = DBHelper();

                  // 📟 [countNewFiles] count new files which are imported
                  // 📟 [countExistFiles] count already existing files in 📁 App Directory
                  int countNewFiles = 0, countExistFiles = 0;

                  // [📄], List of All PDF files picked by the user
                  List<File>? pdfFiles = await PdfUtils.pickPDFFiles();

                  if (pdfFiles != null) {
                    // updating [isImporting] to 1️⃣ true
                    // showing 🌀 CircularProgressIndicator() on FAB
                    updateIsImporting(true);

                    // 🗨️ Showing File is Importing Message
                    showSnackBar(
                        context, kImportingFilesMessage, _messengerKey);

                    for (File pdfFile in pdfFiles) {
                      // 🤔 Checking if the [pdfFile] #️⃣ Already Exist in 🗄️ Database or not
                      if (await Utils.isHashExists(pdfFile)) {
                        countExistFiles++;
                        continue;
                      } else {
                        // ⚙️ Generating [pdfModel] for [pdfFile]
                        PDFModel pdfModel = await PdfUtils.getPdfModelOfFile(
                            pdfFile, pdfFileNameAlreadyInDir);

                        // 📥 Saving [pdfModel] in 🗄️ Database
                        dbHelper.savePdf(pdfModel);
                        countNewFiles++;

                        // ➕ Updating [item]
                        context
                            .read<PDFItemModel>()
                            .updateItem(await Utils.getPDFDataFromDB());
                      }
                    }
                  }

                  // if [countNewFiles] > 0, means some new files is been 📥 saved in the 🗄️ Database
                  if (countNewFiles > 0) {
                    // updating [isImporting] to 0️⃣ false
                    // showing ➕ on FAB
                    updateIsImporting(false);

                    // 🔥 Deleting Cache
                    Utils.deleteCache();
                    // 📝 Set [dbIsEmpty] to true, if set to false
                    if (dbIsEmpty) {
                      setState(() {
                        dbIsEmpty = false;
                      });
                    }

                    // 🗨️, Files Imported Successfully SnackBar
                    String text = Utils.getFileOrFilesText(countNewFiles);
                    showSnackBar(
                        context, "$text $kImportedSuccessfully", _messengerKey);
                  }

                  // if [countExistFiles] > 0
                  // means some files user selected already exists in the 🗄️ Databse
                  if (countExistFiles > 0) {
                    // 🗨️, Files already in the 🗄️ Database SnackBar
                    String text = Utils.getFileOrFilesText(countExistFiles);
                    showSnackBar(context, "$text $kAlreadyInDB", _messengerKey);
                  }
                } else {
                  // 🗨️, [isImporting] = 1️⃣ true
                  // showing 🌀 CircularProgressIndicator() on FAB
                  showSnackBar(context, "Files Are Importing, Please Wait",
                      _messengerKey);
                }
              } else {
                // 🗨️, 🙏 Permission not Granted
                showSnackBar(context, "$kGivePermissionTextFAB", _messengerKey);
              }
              FilePicker.platform.clearTemporaryFiles();
            },
            child: (isImporting)
                ?
                // 🌀
                CircularProgressIndicator(
                    color: Colors.white,
                  )
                :
                // ➕
                Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  /// 🥇 Run Before the [Home]'s [build] method
  @override
  void initState() {
    super.initState();
    Utils.createFolderIfNotExist();
    setstoragePermissionStatus();
    setDBIsEmpty();
    recievePDF(
        context: context,
        key: _messengerKey,
        updateIsImporting: updateIsImporting);
  }

  /// 🤝 Handles 🔙🔙 Double Back to Exit
  ///
  /// 2 Second Duration
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currBackPressTime == null ||
        now.difference(currBackPressTime!) > Duration(seconds: 2)) {
      currBackPressTime = now;
      showSnackBar(context, "Press once again to exit", _messengerKey);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  /// 📝🗄️
  ///
  /// Set [dbIsEmpty]
  ///   - true = 🗄️ Database is empty
  ///   - false = 🗄️ Database have data
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

  /// 📝🙏
  ///
  /// Set Storage Persmission Status
  ///   - true = Granted
  ///   - false = Denied
  void setstoragePermissionStatus() async {
    storagePermissionStatus = await reqP.getStoragePermissionStatus();
  }

  /// 📝 Updating value of [isImporing]
  ///
  ///   - true = 🌀 on FAB
  ///   - false = ➕ on FAB
  void updateIsImporting(bool value) {
    setState(() {
      isImporting = value;
    });
  }
}
