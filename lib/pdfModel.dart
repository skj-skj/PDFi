import 'package:pdf_indexing/functions/utils.dart' as Utils;

class PDFModel {
  final String path;
  final String pdfText;
  final String tags;
  final String hash;
  final String folder;

  PDFModel({
    required this.path,
    required this.pdfText,
    required this.tags,
    required this.hash,
    required this.folder,
  });

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

  @override
  String toString() {
    return 'pdf_table(filename: ${Utils.getFileNameFromPath(path)}, path: $path, pdfText: $pdfText, tags: $tags, hash: $hash, folder: $folder)';
  }
}
