import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_text/pdf_text.dart';

void main() {
  runApp(MyHome());
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("PDF - Indexing"),
        ),
        body: Container(
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  print("import pressed");
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf']);
                  if(result!=null){
                    PlatformFile pdfFile = result.files.first;
                    Directory? storageLocation = await getExternalStorageDirectory();
                    print(storageLocation!.path);
                    
                      File pdfFileCached = File(pdfFile.path.toString());
                      print(pdfFileCached.absolute);
                      await  pdfFileCached.copy("${storageLocation.path}/${pdfFile.name}");

                    
                    // File('$storageLocation/${pdfFile.name}').writeAsBytesSync(pdfFile.bytes!.toList());
                    // print("${pdfFile.bytes}");
                  }
    
                },
                child: Text("Import"),
              ),
              TextButton(onPressed: () async {
                    Directory? storageLocation = await getExternalStorageDirectory();

                    List<FileSystemEntity> files = storageLocation!.listSync();

                    PDFDoc doc = await PDFDoc.fromPath(files[0].path);
                    PDFPage page = doc.pageAt(1);
                    String pageText = await page.text;
                    print(pageText);
    
              }, child: Text('Extract Data')),
            ],
          ),
        ),
      ),
    );
  }
}
