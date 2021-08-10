import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:pdf_indexing/constants.dart';
import 'package:pdf_indexing/functions/utils.dart' as Utils;
import 'package:pdf_indexing/pdfModel.dart';
import 'package:pdf_text/pdf_text.dart';

Future<PDFModel> getPdfModelOfFile(
    File pdfFile, List<String> filenamesInDir) async {
  String storagePath = await Utils.getStoragePath();
  List<String> filename = Utils.getFileNameAndExtentionFromPath(pdfFile.path);
  String filenameToUse = '';

  //Generate filename if same filename already exists
  int count = 0;
  String tempFileName = '${filename[0]}.${filename[1]}';
  while (true) {
    if (!filenamesInDir.contains(tempFileName)) {
      filenameToUse = tempFileName;
      print("File New Name 2: $filename");

      break;
    } else {
      print("File Name Exists: $filename");
      count++;
      tempFileName = '${filename[0]}-$count.${filename[1]}';
      print("File New Name: $tempFileName");
    }
  }
  print("File New Name 3: $filename");

  File pdfSavedFile =
      await pdfFile.copy(join(storagePath, kPdfFilesPath, filenameToUse));

  // Extracting Text from pdf
  PDFDoc doc = await PDFDoc.fromFile(pdfSavedFile);
  PDFPage page = doc.pageAt(1);
  String pageText = await page.text;

  // Generating SHA1 Hash
  String hash = await Utils.getSHA1Hash(pdfSavedFile);

  PDFModel pdfModel = PDFModel(
      path: pdfSavedFile.path,
      pdfText: pageText,
      tags: '',
      hash: hash,
      folder: '');
  return pdfModel;
}

Future<List<File>?> pickPDFFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    allowMultiple: true,
  );
  if (result != null) {
    return result.paths.map((path) => File(path!)).toList();
  } else {
    return null;
  }
}
