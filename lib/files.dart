///Файл, в котором описаны методы для сохранения данных на устройство
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:sornyaki_ai/start.dart';


///Метод сохраняет json-файл
Future saveJson() async {
  final List<int> codeUnits = StartState.jsondata.toString().codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);
  await FileSaver.instance.saveAs(
      name: "jsonOutput",
      bytes: unit8List,
      ext: "json",
      mimeType: MimeType.json);
}

///Метод сохраняет маску на устройстве
Future savePhoto() async{
  await FileSaver.instance.saveAs(
      name: "photoOutput",
      bytes: StartState.maskbyteslist,
      ext: "jpeg",
      mimeType: MimeType.jpeg,
      file: StartState.mask,
  );

}