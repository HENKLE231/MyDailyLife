import 'package:flutter/material.dart';
import 'package:my_daily_life/LoginPage.dart';
import 'package:my_daily_life/FirebaseCustom.dart';

void main() {
  // FirebaseHelper.initDatabase();//ALTERAR Fazer funcionar
  runApp(MaterialApp(
    title: "My Daily Life",
    theme: ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
    ),
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
