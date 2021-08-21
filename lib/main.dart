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
import 'package:pdf_indexing/functions/docUtils.dart' as DOCUtils;
import 'package:pdf_indexing/functions/recieve_doc.dart';
import 'package:pdf_indexing/functions/request_permission.dart' as reqP;
import 'package:pdf_indexing/functions/snackbar.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/doc_item_model.dart';
import 'package:pdf_indexing/model/doc_model.dart';
import 'package:pdf_indexing/model/progress_model.dart';
import 'package:pdf_indexing/widgets/action_buttons.dart';
import 'package:pdf_indexing/widgets/search_widget.dart';

void main() {
  runApp(
    /// ✅ Implementation of Provider State Management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DOCItemModel()),
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

  /// is App is currently importing documents
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
                        ? Consumer<DOCItemModel>(
                            builder: (context, docItem, child) {
                              return Wrap(
                                children:
                                    (context.read<DOCItemModel>().items.length >
                                            0)
                                        ? context.read<DOCItemModel>().items
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
                                updateIsImporting(false);
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
                  // 🤔 Checking if Currently App is Imporing documents files or not
                  if (!isImporting) {
                    // updating [isImporting] to 1️⃣ true
                    // showing 🌀 CircularProgressIndicator() on FAB
                    updateIsImporting(true);

                    // List of Filename in the 📁 App Directory
                    List<String> docFileNameAlreadyInDir =
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

                    // [📄], List of All Documents files picked by the user
                    List<File>? docFiles = await DOCUtils.pickDOCFiles();

                    // 📝 Setting Default Value of Current & Total
                    // For Progress
                    context.read<ProgressModel>().setDefaultValue();

                    if (docFiles != null) {
                      // 📝 Set Total Values = Total No of Files user Selected
                      context
                          .read<ProgressModel>()
                          .updateTotalValue(docFiles.length);

                      // 🗨️ Showing File is Importing Message
                      showSnackBar(
                          context, kImportingFilesMessage, _messengerKey);

                      for (File docFile in docFiles) {
                        // ➕ Updating the progress of Current Value by 1
                        context.read<ProgressModel>().currentValueIncrement();

                        // 🤔 Checking if the [docFile] #️⃣ Already Exist in 🗄️ Database or not
                        if (await Utils.isHashExists(docFile)) {
                          countExistFiles++;
                          continue;
                        } else {
                          try {
                            // ⚙️ Generating [docModel] for [docFile]
                            DOCModel docModel =
                                await DOCUtils.getDOCModelOfFile(
                                    docFile, docFileNameAlreadyInDir);
                            // 🤔 Checking if the [docModel] is not Null Model
                            if (docModel.path != 'null') {
                              // 📥 Saving [docModel] in 🗄️ Database
                              dbHelper.saveDOC(docModel);
                              countNewFiles++;
                            } else {
                              countCorrupt++;
                            }
                            // ➕ Updating [item]
                            context
                                .read<DOCItemModel>()
                                .updateItem(await Utils.getDOCDataFromDB());

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
                  updateIsImporting(false);
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
    recieveDOC(
        context: context,
        key: _messengerKey,
        updateIsImporting: updateIsImporting);
    updateSQLDatabase();
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

  void updateSQLDatabase(){
    DBHelper dbH = DBHelper();
    dbH.getTableNames();
  }
}
