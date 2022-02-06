// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

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
    allowedExtensions: ['pdf', 'xls', 'xlsx', 'docx'],
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
Future<String> extractText(File file) async {
  try {
    if (Utils.isPDF(file.path)) {
      /// 📤 Extracting Text from PDF [file], at page 1
      PDFDoc doc = await PDFDoc.fromFile(file);
      PDFPage page = doc.pageAt(1);
      return (await page.text);
    } else if (Utils.isSpreadSheet(file.path)) {
      /// 📤 Extracting Text from XLSX [file]
      Uint8List bytes = file.readAsBytesSync();
      SpreadsheetDecoder decoder = SpreadsheetDecoder.decodeBytes(bytes);
      List<String> sheets = decoder.tables.keys.toList();
      String text = '';
      sheets.forEach((sheet) {
        // int rows = decoder.tables[sheet]!.maxRows;
        // int cols = decoder.tables[sheet]!.maxCols;
        decoder.tables[sheet]!.rows.forEach((row) {
          row = row.where((element) => element != null).toList();
          text += "${row.join(' ')}\n";
        });
      });
      // Limiting Number of Charaters to 5000 in 'text'
      if (text.length > 5000){
        text = text.substring(0,5001);
      }
      return text;
    } else if (Utils.isWordDoc(file.path)){
      /// e📤 Extracting Text from DOCX [file]
      return Utils.docxParser(file);
    }
  } catch (e) {
    print("Error while Extracting Text");
  }

  /// ❗✖️ if faild to Extract text
  /// returns '' (Empty String)
  return '';
}

/// 📤🖼️ Extract Thumbnail of Documents
/// TODO: Implement Thumbail Genration for Spread Sheet
Future<Uint8List> extractThumb(File file) async {
  try {
    if (Utils.isPDF(file.path)) {
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
    } else if (Utils.isSpreadSheet(file.path)) {
      /// If file is spread sheet or xlsx
      ///
      /// Returns Uint8List representation of 'xlsx_icon_256.png'
      return kXLSXUint8List;
    } else if (Utils.isWordDoc(file.path)){
      /// if file is word doc or docx
      /// 
      /// Returns Uint8List representation of 'docx_icon_256.png'
      return kDOCXUint8List;
    }
  } catch (e) {
    print("Error While Generating Thumbnail");
    print(e);
  }

  /// ❗✖️ If faild to Extract 🖼️ Thumbnail,
  ///
  /// Returns Uint8List representation of 'file_error.png'
  return kFileErrorUint8List;
}
