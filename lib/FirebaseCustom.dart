
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firebase.dart'; 

class FirebaseHelper{
  static fb.Database initDatabase() {
    try {
      if (fb.apps.isEmpty) {//ALTERAR COMPLETAR
        fb.initializeApp(
          apiKey: "",
          authDomain: "",
          databaseURL: "https://my-daily-life-aec95-default-rtdb.firebaseio.com",
          projectId: "my-daily-life-aec95",
          storageBucket: "",
          messagingSenderId: "583782514794",
          appId: "1:583782514794:android:f25fa3c50c59b55cc94a13",
          measurementId: ""
        );
      }
    } on fb.FirebaseJsNotLoadedException catch (e) {
      print(e);
    }
    return fb.database();
  }
}

class Fire{
  static fb.Database database = FirebaseHelper.initDatabase();
}

Future<String> getOnce(fb.DatabaseReference AdsRef) async {
  String aux = "";
  await AdsRef.once('value').then((value) => {aux = value.snapshot.val()});
  return aux;
}

Future<List> getList(fb.DatabaseReference AdsRef) async {
  List list = [""];
  await AdsRef.once('value').then((value) => {list = result(value.snapshot, list)});
  return list;
}

List result(DataSnapshot dp, List list) {
  list.clear();
  dp.forEach((v) => list.add(v));
  return list;
}