// 🎯 Dart imports:
import 'dart:typed_data';

// 🌎 Project imports:
import 'package:pdf_indexing/functions/utils.dart' as Utils;

/// 🧰 [DOCModel], used to create a [docModel] and 📥 Save to 🗄️ Database
///
/// Contains
///   - 🔠 path, 🖼️ Thumb, 🔠🔡 dicText, 🏷️ tags, #️⃣ hash, 📁 folder
class DOCModel {
  /// 🔠 [path], Contains path of the [docFile]
  final String path;

  /// 🖼️ [thumb], Contains Thumbnail Byte Data of [docFile]
  final Uint8List thumb;

  /// 🔠🔡 [docText], Contains text ⚙️📤 Extracted from 🥇 1st page of docFile
  final String docText;

  /// 🏷️ [tags], Contains tags for the docFile,
  ///
  /// By Default tags = ''
  ///
  /// User can ➕ Create their own 🏷️ [tags] to 🔎 identify the docFile
  final String tags;

  /// #️⃣ [hash], Contains [SHA1] #️⃣ of docFile
  final String hash;

  /// 📁 [folder], Contains folder name to 🗃️ Organise docFiles
  ///
  /// By Defalut folder = ''
  ///
  /// User can ➕ Add docFile to any [folders]
  final String folder;

  DOCModel({
    required this.path,
    required this.thumb,
    required this.docText,
    required this.tags,
    required this.hash,
    required this.folder,
  });

  /// 🗺️ toMap()
  ///
  /// ⚙️ Create Map of docModel, Contains:
  ///   - 🔠 filename, 🔠 path, 🖼️ thumb 🔠🔡 docText, 🏷️ tags, #️⃣ hash, 📁 folder
  Map<String, dynamic> toMap() {
    return {
      'filename': Utils.getFileNameFromPath(path),
      'path': path,
      'thumb': thumb,
      'docText': docText.trim().removeLongSpace(),
      'tags': tags,
      'hash': hash,
      'folder': folder
    };
  }

  /// 🔠🔡🔤 toString() of [docModel]
  ///
  /// Contains:
  ///   - 🔠 filename, 🔠 path, 🔠🔡 docText, 🏷️ tags, #️⃣ hash, 📁 folder
  @override
  String toString() {
    return 'docModel(filename: ${Utils.getFileNameFromPath(path)}, path: $path, docText: $docText, tags: $tags, hash: $hash, folder: $folder)';
  }
}

extension on String{
  String removeLongSpace() => this.replaceAll(RegExp('\\s+'), ' ');
}