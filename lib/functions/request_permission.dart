// 📦 Package imports:
import 'package:permission_handler/permission_handler.dart';

/// ⏩0️⃣/1️⃣
///
/// 🔭 Return Storage Permission Status
///   * true = Permission Given
///   * false = Permission 🚫 Given
Future<bool> getStoragePermissionStatus() async {
  PermissionStatus storagePermissionStatus = await Permission.storage.status;
  return storagePermissionStatus.isGranted;
}

// not in use currently
Future<void> requestPermission() async {
  PermissionStatus storageStatus = await Permission.storage.status;
  if (storageStatus.isDenied) {
    final status = await Permission.storage.request();
    print(status);
  } else {
    print('Already Granted');
  }
}

/// ⏩0️⃣/1️⃣
///
/// 🙏 Requesting Storage Permission
/// true = if Granted
/// false = if 🚫 Granted
Future<bool> requestStoragePermission() async {
  final status = await Permission.storage.request();
  return status.isGranted;
}
