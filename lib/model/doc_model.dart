// π― Dart imports:
import 'dart:typed_data';

// π Project imports:
import 'package:pdf_indexing/functions/utils.dart' as Utils;

/// π§° [DOCModel], used to create a [docModel] and π₯ Save to ποΈ Database
///
/// Contains
///   - π  path, πΌοΈ Thumb, π π‘ dicText, π·οΈ tags, #οΈβ£ hash, π folder
class DOCModel {
  /// π  [path], Contains path of the [docFile]
  final String path;

  /// πΌοΈ [thumb], Contains Thumbnail Byte Data of [docFile]
  final Uint8List thumb;

  /// π π‘ [docText], Contains text βοΈπ€ Extracted from π₯ 1st page of docFile
  final String docText;

  /// π·οΈ [tags], Contains tags for the docFile,
  ///
  /// By Default tags = ''
  ///
  /// User can β Create their own π·οΈ [tags] to π identify the docFile
  final String tags;

  /// #οΈβ£ [hash], Contains [SHA1] #οΈβ£ of docFile
  final String hash;

  /// π [folder], Contains folder name to ποΈ Organise docFiles
  ///
  /// By Defalut folder = ''
  ///
  /// User can β Add docFile to any [folders]
  final String folder;

  DOCModel({
    required this.path,
    required this.thumb,
    required this.docText,
    required this.tags,
    required this.hash,
    required this.folder,
  });

  /// πΊοΈ toMap()
  ///
  /// βοΈ Create Map of docModel, Contains:
  ///   - π  filename, π  path, πΌοΈ thumb π π‘ docText, π·οΈ tags, #οΈβ£ hash, π folder
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

  /// π π‘π€ toString() of [docModel]
  ///
  /// Contains:
  ///   - π  filename, π  path, π π‘ docText, π·οΈ tags, #οΈβ£ hash, π folder
  @override
  String toString() {
    return 'docModel(filename: ${Utils.getFileNameFromPath(path)}, path: $path, docText: $docText, tags: $tags, hash: $hash, folder: $folder)';
  }
}

extension on String {
  /// to remove π₯πΎ long spaces in the text
  String removeLongSpace() => this.replaceAll(RegExp('\\s+'), ' ');
}
