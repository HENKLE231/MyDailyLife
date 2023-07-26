import 'package:firebase/firebase.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:my_daily_life/FirebaseCustom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseDB{
  static FirebaseDB firebaseDbInstance = FirebaseDB();
  String path = "accounts";

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _userIndex = prefs.getInt("_userIndex") ?? 0;
    String _name = prefs.getString("name$_userIndex") ?? "";
    String _email = prefs.getString("email$_userIndex") ?? "";
    String _password = prefs.getString("password$_userIndex") ?? "";
    List<String>_titles = prefs.getStringList("titles$_userIndex") ?? [];
    List<String>_pages = prefs.getStringList("pages$_userIndex") ?? [];

    FirebaseDatabaseWeb.instance.reference().child(path).child(_email).child("name").set(_name);
    FirebaseDatabaseWeb.instance.reference().child(path).child(_email).child("email").set(_email);
    FirebaseDatabaseWeb.instance.reference().child(path).child(_email).child("password").set(_password);
    for(int i = 0; i < _titles.length; i++) {
      FirebaseDatabaseWeb.instance.reference().child(path).child(_email).child("titles").child("title$i").set(_titles[i]);
    }
    for(int i = 0; i < _pages.length; i++) {
      FirebaseDatabaseWeb.instance.reference().child(path).child(_email).child("pages").child("page$i").set(_pages[i]);
    }

    if (FirebaseDatabaseWeb.instance.reference().child(path).child(_email).key == _email) {
      print("Cadastrado com sucesso!");
    } else {
      print("Não cadastrado...");
    }
  }

  //ALTERAR salvar na pref
  void loadAccountData() async {
    // List data = await getList(Fire.database.ref(path));
    List data = await getList(Fire.database.ref(path));
    print(data);
    
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> users = prefs.getStringList("users") ?? [];
    // int _userIndex = prefs.getInt("_userIndex") ?? 0;
    // String _name = prefs.getString("name$_userIndex") ?? "";
    // String _email = prefs.getString("email$_userIndex") ?? "";
    // String _password = prefs.getString("password$_userIndex") ?? "";
    // List<String>_titles = prefs.getStringList("titles$_userIndex") ?? [];
    // List<String>_pages = prefs.getStringList("pages$_userIndex") ?? [];

    // prefs.setString("name$_userIndex", name);
    // prefs.setString("email$_userIndex", email);
    // prefs.setString("password$_userIndex", password);
    // prefs.setStringList("titles$_userIndex", titles);
    // prefs.setStringList("pages$_userIndex", pages);
    // prefs.setStringList("users", users);
    // prefs.setString("_lastUser", name); //MUDAR Ver Necessidade
  }

  void deleteAccount() {
    //ALTERAR DPS CRIAR E PUXAR DO PREFS P PEGAR COMO ID///////////////////////////////////////////////////////
    String _email = "";
    FirebaseDatabaseWeb.instance.reference().child(path).child(_email).remove();
  }
}