// 🌎 Project imports:
import 'package:pdf_indexing/functions/utils.dart' as Utils;

/// 🧰 [PDFModel], used to create a [pdfModel] and 📥 Save to 🗄️ Database
///
/// Contains
///   - 🔠 path,🔠🔡 pdfText,🏷️ tags,#️⃣ hash,📁 folder
class PDFModel {
  /// 🔠 [path], Contains path of the [pdfFile]
  final String path;

  /// 🔠🔡 [pdfText], Contains text ⚙️📤 Extracted from 🥇 1st page of pdfFile
  final String pdfText;

  /// 🏷️ [tags], Contains tags for the pdfFile,
  ///
  /// By Default tags = ''
  ///
  /// User can ➕ Create their own 🏷️ [tags] to 🔎 identify the pdfFile
  final String tags;

  /// #️⃣ [hash], Contains [SHA1] #️⃣ of pdfFile
  final String hash;

  /// 📁 [folder], Contains folder name to 🗃️ Organise pdfFiles
  ///
  /// By Defalut folder = ''
  ///
  /// User can ➕ Add pdfFile to any [folders]
  final String folder;

  PDFModel({
    required this.path,
    required this.pdfText,
    required this.tags,
    required this.hash,
    required this.folder,
  });

  /// 🗺️ toMap()
  ///
  /// ⚙️ Create Map of pdfModel, Contains:
  ///   - 🔠 filename, 🔠 path, 🔠🔡 pdfText, 🏷️ tags, #️⃣ hash, 📁 folder
  Map<String, String> toMap() {
    return {
      'filename': Utils.getFileNameFromPath(path),
      'path': path,
      'pdfText': pdfText,
      'tags': tags,
      'hash': hash,
      'folder': folder
    };
  }

  /// 🔠🔡🔤 toString() of [pdfModel]
  ///
  /// Contains:
  ///   - 🔠 filename, 🔠 path, 🔠🔡 pdfText, 🏷️ tags, #️⃣ hash, 📁 folder
  @override
  String toString() {
    return 'pdfModel(filename: ${Utils.getFileNameFromPath(path)}, path: $path, pdfText: $pdfText, tags: $tags, hash: $hash, folder: $folder)';
  }
}
