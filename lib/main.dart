import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sornyaki_ai/start.dart';
import 'package:sornyaki_ai/theme.dart';
import 'db_link.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await initFireBase();
  await LinkToScript.gl();
  runApp(MaterialApp(
    theme: theme(),
    builder: EasyLoading.init(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Start(),
    },
  ));
}


Future<bool> initFireBase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  return true;
}