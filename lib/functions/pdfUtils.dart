// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:pdf_text/pdf_text.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/pdfModel.dart';

/// ⏩🧰 Return PDFModel
///
/// ⚙️ Generate PDFModel of [pdfFile]
Future<PDFModel> getPdfModelOfFile(
    File pdfFile, List<String> filenamesInDir) async {
  String storagePath = await Utils.getStoragePath();
  List<String> filename = Utils.getFileNameAndExtentionFromPath(pdfFile.path);
  String filenameToUse = '';

  /// ⚙️ Generate New filename [filenameToUse]
  /// if, old filename [filename[0]] already exist in 📁 Directory
  int count = 0;
  String tempFileName = '${filename[0]}.${filename[1]}';
  while (true) {
    if (!filenamesInDir.contains(tempFileName)) {
      filenameToUse = tempFileName;
      break;
    } else {
      count++;
      tempFileName = '${filename[0]}-$count.${filename[1]}';
    }
  }

  /// 📥 Save [pdfFile] in App Directory
  File pdfSavedFile =
      await pdfFile.copy(join(storagePath, kPdfFilesPath, filenameToUse));

  /// 📤 Extracting Text from [pdfSavedFile], at page 1
  PDFDoc doc = await PDFDoc.fromFile(pdfSavedFile);
  PDFPage page = doc.pageAt(1);
  String pageText = await page.text;

  /// ⚙️ Generating [SHA1] #️⃣ of [pdfSavedFile]
  String hash = await Utils.getSHA1Hash(pdfSavedFile);

  /// ⚙️🧰 Creating pdfModel
  PDFModel pdfModel = PDFModel(
      path: pdfSavedFile.path,
      pdfText: pageText,
      tags: '',
      hash: hash,
      folder: '');

  return pdfModel;
}

/// ⏩[📄]?
///
/// Return [File,]?
/// 🗃️ Pick PDF file from [FilePicker]
/// Can pick multiple File
Future<List<File>?> pickPDFFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    allowMultiple: true,
  );

  /// 🗺️ Results
  /// path -> File(path)
  if (result != null) {
    return result.paths.map((path) => File(path!)).toList();
  } else {
    return null;
  }
}
