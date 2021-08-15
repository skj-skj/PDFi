// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
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

  /// 📄 [pdfSavedFile] is File, when file is saved in app directory
  /// pdfSavedFile refers to that
  File pdfSavedFile;

  /// 🔠 Will contain text of 1st page of [pdfSavedFile]
  String pageText;

  /// 🖼️ Will store the thumbnail of [pdfSavedFile]
  Uint8List thumb;

  try {
    /// 📥 Save [pdfFile] in App Directory
    pdfSavedFile =
        await pdfFile.copy(join(storagePath, kPdfFilesPath, filenameToUse));
  } catch (e) {
    /// ❗✖️ if faild to saved pdf file to app directory
    /// Null pdfModel will return
    return kNullPDFModel;
  }
  try {
    /// 📤 Extracting Text from [pdfSavedFile], at page 1
    PDFDoc doc = await PDFDoc.fromFile(pdfSavedFile);
    PDFPage page = doc.pageAt(1);
    pageText = await page.text;
  } catch (e) {
    /// ❗✖️ if faild to Extract text
    /// [pageText] = '' (Empty String)
    pageText = '';
  }

  try {
    /// 📤 Extracting Thumbnail Image from [pdfSavedFile], at page 1
    ///
    /// JPEG Format
    PdfDocument document =
        await PdfDocument.openData(pdfSavedFile.readAsBytesSync());
    final pageThumb = await document.getPage(1);
    final pageThumbImage = await pageThumb.render(
      width: pageThumb.width ~/ 4,
      height: pageThumb.height ~/ 4,
      format: PdfPageFormat.JPEG,
    );
    thumb = pageThumbImage!.bytes;
  } catch (e) {
    /// ❗✖️ If faild to Extract 🖼️ Thumbnail,
    /// Thumbnail of "no_file_found.png" will be saved in thumb
    thumb = (await rootBundle.load('assets/images/no_file_found.png'))
        .buffer
        .asUint8List();
  }

  /// ⚙️ Generating [SHA1] #️⃣ of [pdfSavedFile]
  String hash = await Utils.getSHA1Hash(pdfSavedFile);

  /// ⚙️🧰 Creating pdfModel
  PDFModel pdfModel = PDFModel(
      path: pdfSavedFile.path,
      thumb: thumb,
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
