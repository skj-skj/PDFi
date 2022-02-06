// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/loaded_assets.dart';

/// 🖼️ Shows Thumbnail
///
/// From [thumb] data stored in 🗄️ Database
///
/// thumb => Uint8List
class Thumbnail extends StatelessWidget {
  /// 🔠 [path]
  ///
  /// path of the [docFile]
  final path;

  /// 🖼️ [thumb]
  ///
  /// thumbnail image of [docFile]
  final Uint8List thumb;

  /// 📟 Image Size
  final double itemImageSize;

  const Thumbnail({
    required this.path,
    required this.thumb,
    required this.itemImageSize,
  });

  /// ⚙️🤔🖼️, return thumnail data
  ///
  /// if file is corrupt =>  return fileError image data
  /// 
  /// if file is xlsx => return xlsx image data
  /// 
  /// if file is docx => return docx image data
  ///
  /// if file is pdf and have thumbnail data saved in 🗄️ Database, [thumb] will be returned
  Uint8List genThumb() {
    if (listEquals(thumb, kFileErrorUint8List)) {
      return LoadedAssets.fileError;
    } else if (listEquals(thumb, kXLSXUint8List)) {
      return LoadedAssets.xlsx;
    } else if (listEquals(thumb, kDOCXUint8List)){
      return LoadedAssets.docx;
    }
    return thumb;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      key: Key(path),
      child: Image.memory(
        genThumb(),
        fit: BoxFit.fitWidth,
        width: itemImageSize - 25,
        height: itemImageSize - 25,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}
