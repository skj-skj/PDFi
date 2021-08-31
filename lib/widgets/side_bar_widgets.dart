// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;

/// 💄 Drawer/Side Bar Header
class SideBarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          kAppTitle,
          style: TextStyle(
            fontSize: 48.0,
            color: Theme.of(context).primaryTextTheme.bodyText1!.color,
          ),
        ));
  }
}

/// 💄🧐 Check For Update Tile
///
/// ListTile for Drawer to Check for New Version of the app
class CheckForUpdateTile extends StatefulWidget {
  @override
  _CheckForUpdateTileState createState() => _CheckForUpdateTileState();
}

class _CheckForUpdateTileState extends State<CheckForUpdateTile> {
  /// 🧐 is App is Checking for update or not
  ///
  ///   - true = 🌀 CircularProgressIndicator() will be shown in leading of ListTile
  ///   - false = ⬇️ arrow_circle_down_rounded / ✅ check_circle_outline_sharp, Icon will be shown in leading of ListTile
  ///
  /// default [false]
  bool isCheckingForUpdate = false;

  /// 🧐 is New Version of the App is Available to Download or not
  ///
  ///   - true = ⬇️ arrow_circle_down_rounded Icon will be shown in leading of ListTile
  ///   - false = ✅ check_circle_outline_sharp Icon will be shown in leading of ListTile
  ///
  /// default [false]
  bool isNewVersionAvailable = false;

  /// 🧐 is Internet is Available or not
  ///
  ///   - true = ✅ Internet Available
  ///   - false = ❎ Internet Not Available
  ///
  /// default [true]
  bool isNetworkAvailable = true;

  /// 🔠 New App Version Download 📎 Link/URL
  ///
  /// default [Empty String] = ''
  String newVersionDownloadUrl = '';

  /// 🔠 New App Version
  ///
  /// default ['0.0.0']
  String newAppVersion = '0.0.0';

  /// 📥 Update [isNetworkAvailable] with setState();
  void updateNetworkAvailable(bool value) {
    setState(() {
      isNetworkAvailable = value;
    });
  }

  /// 📥 Update [isCheckingForUpdate] with setState();
  void updateCheckingForUpdate(bool value) {
    setState(() {
      isCheckingForUpdate = value;
    });
  }

  /// 📥 Update [isNewVersionAvailable] with setState();
  void updateNewVersionAvailable(bool value) {
    setState(() {
      isNewVersionAvailable = value;
    });
  }

  /// 🧐 Checking for Update Method
  ///
  ///   - New Version Available - Alert Dialog shown to Download the New Version
  ///   - Using Latest Version - ALert Dialog shown to inform user the App is UpToDate
  Future<void> checkForUpdate() async {
    updateCheckingForUpdate(true);

    // 📥🗞️ Gets Current App Info in [currAppInfo]
    Map<String, String> currAppInfo = await Utils.getCurrAppInfo();

    // 📝 Sets [kNullAppVersionJSON] to [updatedAppInfo], default value if Internet is not available
    var updatedAppInfo = kNullAppVersionJSON;
    // 🧐 Checking for Internet
    if (await Utils.hasNetwork()) {
      // 📥 Gets New App Version Info
      updatedAppInfo = await Utils.getNewAppVersion(info: currAppInfo);
      isNetworkAvailable = true;
    } else {
      isNetworkAvailable = false;
    }
    newAppVersion = updatedAppInfo['version'].toString();
    updateCheckingForUpdate(false);

    // 🧐 Checking if New App Version is Greater than Current App Version
    // - true = if New App Version > Current App Version
    // - false = if New App Version <= Current App Version
    if (newAppVersion.compareTo(currAppInfo["v"] ?? '0.0.0') > 0) {
      updateNewVersionAvailable(true);
      newVersionDownloadUrl = updatedAppInfo['url'];
    } else {
      updateNewVersionAvailable(false);
    }
  }

  @override
  void initState() {
    super.initState();
    // 🧐 Check Only For Updates and 💄 Update the Leading in ListTile
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (isCheckingForUpdate)
          ? SizedBox(
              child: CircularProgressIndicator(),
              width: 42.0,
              height: 42.0,
            )
          : (isNewVersionAvailable)
              ? Icon(
                  Icons.arrow_circle_down_rounded,
                  size: 42.0,
                  color: Colors.green,
                )
              : Icon(
                  Icons.check_circle_outline_sharp,
                  size: 42.0,
                  color: Theme.of(context).accentColor,
                ),
      title: Text(
        "Check For Update",
        style: TextStyle(fontSize: 16.0),
      ),
      onTap: () async {
        // 🧐 Check for Update
        await checkForUpdate();

        // 🗨️❗, Show Alert Dialog According to [isNewVersionAvailable], [isNetworkAvailable]
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: isNewVersionAvailable ? Text("Update Available") : null,
                content: !isNewVersionAvailable
                    ? Text(isNetworkAvailable
                        ? "Your Are Using Latest Version Of App"
                        : "Can't Connect to the Network")
                    : Text("Version: $newAppVersion \nAvailable To Download"),
                actions: [
                  if (isNewVersionAvailable) ...[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    )
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      if (isNewVersionAvailable) {
                        if (await canLaunch(newVersionDownloadUrl)) {
                          await launch(newVersionDownloadUrl);
                        } else {
                          throw "Could Not Lounch $newVersionDownloadUrl";
                        }
                      }
                      Navigator.of(context).pop();
                    },
                    child:
                        isNewVersionAvailable ? Text("Download") : Text("OK"),
                  ),
                ],
              );
            });
      },
    );
  }
}
