///Основной файл в приложении, работает с сервером и пользователем
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

    ///Задаем значение ссылке на сайт, получается из бд
    super.initState();
  }

  ///Маркеры отображения элементов интерфейса
  static bool isFileLoaded = false;
  static bool isResponsed = false;
  bool _buttonsEnabled = true;
  bool _isJsonHere = false;

  ///Счетчикики ответов
  int osot = -1;
  int bodyak = -1;
  int schavel = -1;

  ///Переменная для хранения полученных с сервера данных
  static Map<String, dynamic> jsondata = {};

  ///массив байтов маски для дальнейшей записи и файл маски
  static Uint8List? maskbyteslist;
  static File? mask;

  ///Файл отображаемый на главном экране приложения
  XFile? image;

  ///Ссылка на сайт
  static String url = "";

  ///Переменная для загрузки фото в приложение
  final ImagePicker picker = ImagePicker();

  ///Метод для получения маски с сервера
  Future parseMask() async {
    http.Response pj = await http.get(Uri.parse("${url.trim()}fotochka"));
    Directory root = await getTemporaryDirectory();
    String directoryPath = root.path + '/returned_mask';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/received_data.jpg';
    await File(filePath).writeAsBytes(pj.bodyBytes);
    setState(() {
      image = XFile(filePath);
      mask = File(filePath);
    });
  }

  ///Метод для отправки запроса на сервер. Запрос состоит из фото для обработки
  ///Как reponse получает json файл с ответом
  Future upload(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(url.trim());
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: p.basename(imageFile.path));
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    http.Response r = await http.Response.fromStream(response);
    jsondata = jsonDecode(r.body.toString());
    await parseMask();
    setState(() {
      isResponsed = true;
      _isJsonHere = true;
    });
    parseJsonData();
  }

  ///Загрузка фото из галереи/камеры в приложение
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    ///Проверка на не пустоту файла картинки
    if (img != null) {
      setState(() {
        image = img;
        _isJsonHere = false;
      });
    }
    if (image != null) {
      isFileLoaded = true;
    }
  }

  ///Подсчет количества сорняков какого-то типа
  int parseJsonData() {
    List a = jsondata["predictions"];
    bodyak = 0;
    osot = 0;
    schavel = 0;
    for (int i = 0; i < a.length; i++) {
      Map<String, dynamic> b = a[i];
      if (b["class"] == 0) {
        bodyak += 1;
      } else if (b["class"] == 1) {
        osot += 1;
      } else if (b["class"] == 2) {
        schavel += 1;
      }
    }
    setState(() {

    });
    return 1;
  }

  ///Функция возвращает виджет, который доступен как '/' в приложении
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
          child: Column(
        children: [
          Visibility(
            visible: isFileLoaded,
            child: const Padding(padding: EdgeInsets.only(top: 50)),
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

              ///Вывод картинки на экран
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
                  top: MediaQuery.of(context).size.height / 150)),
          Visibility(
            visible: _isJsonHere,
            child: Text(
              "Осот: $osot Бодяк: $bodyak Щавель: $schavel",
              style: TextStyle(fontSize: 19),
            ),
          ),
          Visibility(
              visible: !_isJsonHere,
              child: const Padding(
                padding: EdgeInsets.only(top: 22),
              )),

          ///Группа кнопок под фото
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 100)),
          _getProcessAnotherPhotoButtons(),
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

  ///Введите текст в начале приложения
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

  ///Icon-button для загрузки файла
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

  ///Кнопка для скачивания json-файла
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

  ///Кнопка для скачивания маски, полученной от сервера
  _getDownloadPhotoButton() {
    if (isResponsed) {
      return ElevatedButton(
        onPressed: () async {
          await savePhoto();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Скачать маску"),
      );
    }
    return const SizedBox();
  }

  ///Кнопки Обработать и Другое фото
  _getProcessAnotherPhotoButtons() {
    if (isFileLoaded) {
      return Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _buttonsEnabled
                  ? () async {
                      ///Блокировка кнопки и вызов функций
                      EasyLoading.show();
                      setState(() {
                        _buttonsEnabled = false;
                        _isJsonHere = false;
                      });
                      File file = File(image!.path);
                      await upload(file);
                      EasyLoading.dismiss();
                      setState(() {
                        _buttonsEnabled = true;
                      });
                    }
                  : null,
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
              onPressed: _buttonsEnabled
                  ? () {
                      ///Блокировка кнопки и вызов функций
                      chooseFilePopUp();
                    }
                  : null,
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

  //AlertDialog для выбора способа выбора фото (Из галереи/Из камеры)
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
                    ///Из галереи
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
                    ///Из камеры
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
