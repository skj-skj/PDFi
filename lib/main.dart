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
import 'package:pdf_indexing/model/progress_model.dart';
import 'package:pdf_indexing/widgets/action_buttons.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';

void main() {
  runApp(
    /// ✅ Implementation of Provider State Management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PDFItemModel()),
        ChangeNotifierProvider(create: (context) => ProgressModel()),
      ],
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
        child: GestureDetector(
          onTap: () {
            // ✖️ Remove Focus from TextField [SearchWidget]
            FocusScopeNode currFocus = FocusScope.of(context);
            if (!currFocus.hasPrimaryFocus && currFocus.hasFocus) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          },
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
                        ? Consumer<PDFItemModel>(
                            builder: (context, pdfItem, child) {
                              return Wrap(
                                children:
                                    (context.read<PDFItemModel>().items.length >
                                            0)
                                        ? context.read<PDFItemModel>().items
                                        : [
                                            Center(
                                              child: Text(kDatabaseEmptyText),
                                            )
                                          ],
                              );
                            },
                          )
                        : Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                requestStoragePermission();
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
                    // updating [isImporting] to 1️⃣ true
                    // showing 🌀 CircularProgressIndicator() on FAB
                    updateIsImporting(true);

                    // List of Filename in the 📁 App Directory
                    List<String> pdfFileNameAlreadyInDir =
                        (await Utils.getFilePathListFromDir())
                            .map((path) => Utils.getFileNameFromPath(path))
                            .toList();

                    // 🗄️ Database Helper
                    DBHelper dbHelper = DBHelper();

                    // 📟 [countNewFiles] count new files which are imported
                    // 📟 [countExistFiles] count already existing files in 📁 App Directory
                    // 📟 [countCorrupt] count corrupt files which user selected
                    int countNewFiles = 0,
                        countExistFiles = 0,
                        countCorrupt = 0;

                    // [📄], List of All PDF files picked by the user
                    List<File>? pdfFiles = await PdfUtils.pickPDFFiles();

                    // 📝 Setting Default Value of Current & Total
                    // For Progress
                    context.read<ProgressModel>().setDefaultValue();

                    if (pdfFiles != null) {
                      // 📝 Set Total Values = Total No of Files user Selected
                      context
                          .read<ProgressModel>()
                          .updateTotalValue(pdfFiles.length);

                      // 🗨️ Showing File is Importing Message
                      showSnackBar(
                          context, kImportingFilesMessage, _messengerKey);

                      for (File pdfFile in pdfFiles) {
                        // ➕ Updating the progress of Current Value by 1
                        context.read<ProgressModel>().currentValueIncrement();

                        // 🤔 Checking if the [pdfFile] #️⃣ Already Exist in 🗄️ Database or not
                        if (await Utils.isHashExists(pdfFile)) {
                          countExistFiles++;
                          continue;
                        } else {
                          try {
                            // ⚙️ Generating [pdfModel] for [pdfFile]
                            PDFModel pdfModel =
                                await PdfUtils.getPdfModelOfFile(
                                    pdfFile, pdfFileNameAlreadyInDir);
                            // 🤔 Checking if the pdfModel is not Null Model
                            if (pdfModel.path != 'null') {
                              // 📥 Saving [pdfModel] in 🗄️ Database
                              dbHelper.savePdf(pdfModel);
                              countNewFiles++;
                            } else {
                              countCorrupt++;
                            }
                            // ➕ Updating [item]
                            context
                                .read<PDFItemModel>()
                                .updateItem(await Utils.getPDFDataFromDB());

                            // if (dbIsEmpty) {
                            //   setState(() {
                            //     dbIsEmpty = false;
                            //   });
                            // }
                          } catch (e) {
                            print("Error While Importing: ${e.toString()}");
                            countCorrupt++;
                            continue;
                          }
                        }
                      }
                    }
                    // updating [isImporting] to 0️⃣ false
                    // showing ➕ on FAB
                    updateIsImporting(false);

                    // 📝 Setting Default Value of Current & Total
                    // For Progress to Restart
                    context.read<ProgressModel>().setDefaultValue();

                    // if [countNewFiles] > 0, means some new files is been 📥 saved in the 🗄️ Database
                    if (countNewFiles > 0) {
                      // 🔥 Deleting Cache
                      Utils.deleteCache();

                      // 🗨️, Files Imported Successfully SnackBar
                      String text = Utils.getFileOrFilesText(countNewFiles);
                      showSnackBar(context, "$text $kImportedSuccessfully",
                          _messengerKey);
                    }

                    // if [countExistFiles] > 0
                    // means some files user selected already exists in the 🗄️ Databse
                    if (countExistFiles > 0) {
                      // 🗨️, Files already in the 🗄️ Database SnackBar
                      String text = Utils.getFileOrFilesText(countExistFiles);
                      showSnackBar(
                          context, "$text $kAlreadyInDB", _messengerKey);
                    }
                    // if [countCorrupt] > 0
                    // means some files which user selected are corrupt
                    if (countCorrupt > 0) {
                      // 🗨️, Files is Corrupt in the 🗄️ Database SnackBar
                      String text = Utils.getFileOrFilesText(countExistFiles);
                      showSnackBar(context, "$text are Corrupt", _messengerKey);
                    }
                  } else {
                    // 🗨️, [isImporting] = 1️⃣ true
                    // showing 🌀 CircularProgressIndicator() on FAB
                    showSnackBar(context, "Files Are Importing, Please Wait",
                        _messengerKey);
                  }
                } else {
                  // 🗨️, 🙏 Permission not Granted
                  showSnackBar(
                      context, "$kGivePermissionTextFAB", _messengerKey);
                  requestStoragePermission();
                }
                FilePicker.platform.clearTemporaryFiles();
              },
              child: (isImporting)
                  ?
                  // 🌀 For Showing CircularProgressIndicator & Percentage
                  // To Show The progress of importing files
                  // Used 📚 [Stack] to show  percentage value inside 🌀 CircularProgressIndicator
                  Stack(
                      children: [
                        // Used [SizedBox] to Increase the size of 🌀 CircularProgressIndicator
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: Consumer<ProgressModel>(
                            // This Shows Percentage of the Progress
                            builder: (context, progressModel, child) {
                              int currValue =
                                  context.read<ProgressModel>().currValue;
                              int totalValue =
                                  context.read<ProgressModel>().totalValue;
                              return Text(
                                  "${((currValue / totalValue) * 100).toInt()}%");
                            },
                            // child: ,
                          ),
                        ),
                      ],
                    )
                  :
                  // ➕, Currently no file is being imported
                  Icon(Icons.add),
            ),
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

  /// 🙏 Requesting Storage Permission
  ///
  /// and sets [storagePermissionStatus]
  ///
  ///   - true = Granted
  ///   - false = Denied
  void requestStoragePermission() async {
    bool permissionStatus = await reqP.requestStoragePermission();
    setState(() {
      storagePermissionStatus = permissionStatus;
    });
  }

  /// 📝🙏
  ///
  /// Set Storage Persmission Status
  ///   - true = Granted
  ///   - false = Denied
  void setstoragePermissionStatus() async {
    bool value = await reqP.getStoragePermissionStatus();
    setState(() {
      storagePermissionStatus = value;
    });
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
