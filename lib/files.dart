import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:sornyaki_ai/start.dart';



Future saveJson() async {
  String a = StartState.jsondata.toString();
  final List<int> codeUnits = a.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);
  await FileSaver.instance.saveAs(
      name: "jsonOutput",
      bytes: unit8List,
      ext: "json",
      mimeType: MimeType.json);
}

Future savePhoto() async{
  await FileSaver.instance.saveAs(
      name: "photoOutput",
      bytes: StartState.maskbyteslist,
      ext: "jpeg",
      mimeType: MimeType.jpeg,
      file: StartState.mask,
  );

}