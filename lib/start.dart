import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as p;
import 'package:file_saver/file_saver.dart';
import 'db_link.dart';
import 'files.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => StartState();
}

class StartState extends State<Start> {
  @override
  void initState() {
    url = LinkToScript.link;
    super.initState();
  }

  static bool isFileLoaded = false;
  static bool isResponsed = false;
  static Map<String, dynamic> jsondata = {};

  XFile? image;
  static String url = "";
  var data = "";
  String testText = "";

  final ImagePicker picker = ImagePicker();

  Future upload(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: p.basename(imageFile.path));
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    http.Response r = await http.Response.fromStream(response);
    jsondata = jsonDecode(r.body.toString());
    setState(() {
      isResponsed = true;
    });
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        image = img;
      });
    }
    if (image != null) {
      isFileLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
          child: Column(
        children: [
          Visibility(
            visible: isFileLoaded,
            child: const Padding(padding: EdgeInsets.only(top: 80)),
          ),
          Visibility(
            visible: !isFileLoaded,
            child: const Padding(padding: EdgeInsets.only(top: 200)),
          ),
          _getChooseFile(),
          Visibility(
            visible: !isFileLoaded,
            child: const Padding(padding: EdgeInsets.only(top: 75)),
          ),
          _getLoadFileButton(),
          image != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3 * 2 - 30,
                    ),
                  ),
                )
              : const SizedBox(),
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 100)),
          _getMainButtons(),
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 100)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _getDownloadFileButton(),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 15)),
            _getDownloadPhotoButton(),
          ]),
        ],
      )),
    ));
  }

  _getChooseFile() {
    if (!isFileLoaded) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Выберите файл",
            style: TextStyle(fontSize: 32),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  _getLoadFileButton() {
    if (!isFileLoaded) {
      return IconButton(
        onPressed: () {
          chooseFilePopUp();
        },
        icon: const Icon(Icons.file_open),
        iconSize: 50,
      );
    }
    return const SizedBox();
  }

  _getDownloadFileButton() {
    if (isResponsed) {
      return ElevatedButton(
        onPressed: () async {
          await saveJson();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Скачать JSON"),
      );
    }
    return const SizedBox();
  }

  _getDownloadPhotoButton() {
    if (isResponsed) {
      return ElevatedButton(
        onPressed: () async {
          await saveJson();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Скачать фото"),
      );
    }
    return const SizedBox();
  }

  _getMainButtons() {
    if (isFileLoaded) {
      return Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                File file = File(image!.path);
                await upload(file);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Обработать"),
            ),
          ],
        ),
        Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 100)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                chooseFilePopUp();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Другое фото'),
            ),
          ],
        ),
      ]);
    }
    return const SizedBox();
  }

  void chooseFilePopUp() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Выберите способ ввода'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await getImage(ImageSource.gallery);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('Из галереи'),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 32)),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('Сделать фото'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
