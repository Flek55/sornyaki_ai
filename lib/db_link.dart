import 'package:supabase_flutter/supabase_flutter.dart';

///Класс получает ссылку на сайт из базы данных
class LinkToScript {
  static String link = "";

  static gl() async {
    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> data = await supabase.from('link').select('id');
    link = data[0]["id"];
  }
}
