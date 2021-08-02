import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  PermissionStatus storageStatus = await Permission.storage.status;
  if (storageStatus.isDenied) {
    final status = await Permission.storage.request();
    print(status);
  } else {
    print('Already Granted');
  }
}

Future<bool> getStoragePermissionStatus() async {
  PermissionStatus storagePermissionStatus = await Permission.storage.status;
  return storagePermissionStatus.isGranted;
}

Future<bool> requestStoragePermission() async {
  final status = await Permission.storage.request();
  return status.isGranted;
}
