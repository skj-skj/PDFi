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
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

// 🌎 Project imports:
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/model/doc_model.dart';

/// ⏩🧰 Return DOCModel
///
/// ⚙️ Generate DOCModel of [docFile]
Future<DOCModel> getDOCModelOfFile(
    File docFile, List<String> filenamesInDir) async {
  String storagePath = await Utils.getStoragePath();
  List<String> filename = Utils.getFileNameAndExtentionFromPath(docFile.path);
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

  /// 📄 [docSavedFile] is File, when file is saved in app directory
  /// docSavedFile refers to that
  File docSavedFile;

  /// 🔠 Will contain text of 1st page of [docSavedFile]
  String pageText;

  /// 🖼️ Will store the thumbnail of [docSavedFile]
  Uint8List thumb;

  try {
    /// 📥 Save [docFile] in App Directory
    docSavedFile =
        await docFile.copy(join(storagePath, kDOCFilesPath, filenameToUse));
  } catch (e) {
    /// ❗✖️ if faild to saved Documents file in app directory
    /// Null docModel will return
    return kNullDOCModel;
  }

  /// ⚙️📤 Extracting Text from [docSavedFile]
  pageText = await extractText(docSavedFile);

  /// ⚙️🖼️ Extracting Thumb from [docSavedFile]
  thumb = await extractThumb(docSavedFile);

  /// ⚙️ Generating [SHA1] #️⃣ of [docSavedFile]
  String hash = await Utils.getSHA1Hash(docSavedFile);

  /// ⚙️🧰 Creating docModel
  DOCModel docModel = DOCModel(
      path: docSavedFile.path,
      thumb: thumb,
      docText: pageText,
      tags: '',
      hash: hash,
      folder: '');

  return docModel;
}

/// ⏩[📄]?
///
/// Return [File,]?
/// 🗃️ Pick Documents file from [FilePicker]
/// Can pick multiple File
Future<List<File>?> pickDOCFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'xls', 'xlsx'],
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

/// 🔠, Generate Text Function
/// TODO: Implement Text Genration for Spread Sheet
Future<String> extractText(File file) async {
  try {
    if (Utils.isPDF(file.path)) {
      /// 📤 Extracting Text from PDF [file], at page 1
      PDFDoc doc = await PDFDoc.fromFile(file);
      PDFPage page = doc.pageAt(1);
      return (await page.text);
    } else if (Utils.isSpreadSheet(file.path)) {
      /// 📤 Extracting Text from XLS [file]
      Uint8List bytes = file.readAsBytesSync();
      SpreadsheetDecoder decoder = SpreadsheetDecoder.decodeBytes(bytes);
      List<String> sheets = decoder.tables.keys.toList();
      String text = '';
      sheets.forEach((sheet) {
        int rows = decoder.tables[sheet]!.maxRows;
        int cols = decoder.tables[sheet]!.maxCols;
        decoder.tables[sheet]!.rows.forEach((row) {
          text += "${row.join(' ')}\n";
        });
      });
      return text;
    } else {
      return '';
    }
  } catch (e) {
    /// ❗✖️ if faild to Extract text
    /// returns '' (Empty String)
    return '';
  }
}

/// 📤🖼️ Extract Thumbnail of Documents
/// TODO: Implement Thumbail Genration for Spread Sheet
Future<Uint8List> extractThumb(File file) async {
  if (Utils.isPDF(file.path)) {
    try {
      /// 📤 Extracting Thumbnail Image from [docSavedFile], at page 1
      ///
      /// JPEG Format
      PdfDocument document = await PdfDocument.openData(file.readAsBytesSync());
      final pageThumb = await document.getPage(1);
      final pageThumbImage = await pageThumb.render(
        width: pageThumb.width ~/ 4,
        height: pageThumb.height ~/ 4,
        format: PdfPageFormat.JPEG,
      );
      return pageThumbImage!.bytes;
    } catch (e) {
      /// ❗✖️ If faild to Extract 🖼️ Thumbnail,
      /// Thumbnail of "no_file_found.png" will be saved in thumb
      return (await rootBundle.load('assets/images/no_file_found.png'))
          .buffer
          .asUint8List();
    }
  } else {
    return (await rootBundle.load('assets/images/no_file_found.png'))
        .buffer
        .asUint8List();
  }
}