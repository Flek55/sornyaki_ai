import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sornyaki_ai/start.dart';
import 'package:sornyaki_ai/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api.dart';
import 'db_link.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ///Делает приложение неповоротным на экране
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: anonkey,
  );

  ///Подключение к бд
  await LinkToScript.gl();

  ///Получение ссылки на сайт из бд
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
