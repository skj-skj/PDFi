// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';

/// 🖼️🧰, Class for Assets
///
/// Data Members are static
///
/// Contains:
///   - fileError = 'file_error.png'
///   - xlsx = 'xlsx_icon_256.png'
///   - docx = 'docx_icon_256.png'
///
/// load fucntion to load all the assets in memory
class LoadedAssets {
  /// 🖼️❌, 'file_error.png' [fileError]
  static Uint8List fileError = Uint8List(0);

  /// 🖼️📄, 'xlsx_icon_256.png' [xlsx]
  static Uint8List xlsx = Uint8List(0);

  /// 🖼️📄, 'docx_icon_256.png' [docx]
  static Uint8List docx = Uint8List(0);

  /// 📥🖼️, load the assets in the memory
  static Future<void> load() async {
    fileError = (await rootBundle.load(kFileErrorImage)).buffer.asUint8List();
    xlsx = (await rootBundle.load(kXLSXFileIcon)).buffer.asUint8List();
    docx = (await rootBundle.load(kDOCXFileIcon)).buffer.asUint8List();
    print("loaded Successfully");
  }
}
