import 'package:cloud_firestore/cloud_firestore.dart';


class LinkToScript{
  static String link = "";

  static gl() async{
    final ds =
    await FirebaseFirestore.instance.collection("link").doc("ssylka").get();
    var linkData = ds.data();
    link = linkData?["link"];
  }
}