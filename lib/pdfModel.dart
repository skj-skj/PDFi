import 'package:pdf_indexing/functions/utils.dart' as Utils;

class PDFModel {
  PDFModel({
    required this.path,
    required this.pdfText,
    required this.keywords,
    required this.hash,
  });

  final String path;
  final String pdfText;
  final String keywords;
  final String hash;

  Map<String, String> toMap() {
    return {
      'filename': Utils.getFileNameFromPath(path),
      'path': path,
      'pdfText': pdfText,
      'keywords': keywords,
      'hash': hash
    };
  }

  @override
  String toString() {
    return 'pdf_table(filename: ${Utils.getFileNameFromPath(path)}, path: $path, pdfText: $pdfText, keywords: $keywords)';
  }
}
