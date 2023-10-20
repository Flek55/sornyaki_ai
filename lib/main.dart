import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sornyaki_ai/start.dart';
import 'package:sornyaki_ai/theme.dart';
import 'db_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


const supabaseUrl = 'https://abveqxcfpcsfsmmalpqy.supabase.co';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);///Делает приложение неповоротным на экране
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFidmVxeGNmcGNzZnNtbWFscHF5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY5Nzc3ODMwNiwiZXhwIjoyMDEzMzU0MzA2fQ.zZsIop4oVbprQhCqxYHOGqyoPa4TAnXa0hb1R6I3Wa8',
  );///Подключение к бд
  await LinkToScript.gl();///Получение ссылки на сайт из бд
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
