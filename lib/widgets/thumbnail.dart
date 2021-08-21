// 🐦 Flutter imports:
import 'package:flutter/material.dart';

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
  final thumb;

  /// 📟 Image Size
  final double itemImageSize;

  const Thumbnail({
    required this.path,
    required this.thumb,
    required this.itemImageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: Key(path),
      child: Image.memory(
        thumb,
        fit: BoxFit.fitWidth,
        width: itemImageSize - 25,
        height: itemImageSize - 25,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}
