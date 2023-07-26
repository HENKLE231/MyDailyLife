import 'package:flutter/material.dart';
import 'package:my_daily_life/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:my_daily_life/firebase_db.dart'; //ALTERAR Fazer funcionar

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  TextEditingController _controllerPasswordConfirmation = TextEditingController();
  late FocusNode _nameFocusNode = FocusNode();
  late FocusNode _emailFocusNode = FocusNode();
  late FocusNode _passwordFocusNode = FocusNode();
  late FocusNode _passwordConfirmationFocusNode = FocusNode();
  String _statusRegister = "";

  _openLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _register() async {
    String name = _controllerName.text.trim();
    String email = _controllerEmail.text.trim();
    String password = _controllerPassword.text.trim();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];
    int _userIndex = users.length;
    List<String> titles = [];
    List<String> pages = [];
    users.add(name);

    prefs.setString("name$_userIndex", name);
    prefs.setString("email$_userIndex", email);
    prefs.setString("password$_userIndex", password);
    prefs.setStringList("titles$_userIndex", titles);
    prefs.setStringList("pages$_userIndex", pages);
    prefs.setStringList("users", users);
    prefs.setString("_lastUser", name);

    // FirebaseDB db = FirebaseDB();//ALTERAR Fazer funcionar
    // db.save();

    _openLoginPage();
  }

  void _checkFields() async {
    String name = _controllerName.text.trim();
    String email = _controllerEmail.text.trim();
    String password = _controllerPassword.text.trim();
    String passwordConfirmation = _controllerPasswordConfirmation.text.trim();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    if (name.isEmpty) {
      _nameFocusNode.requestFocus();
      setState(() {
        _statusRegister = "Preencha o campo nome.";
      });
    } else {
      bool access = true;
      for (int i = 0; i < users.length; i++) {
        if (users[i] == name) {
          access = false;
        }
      }
      if (!access) {
        _nameFocusNode.requestFocus();
        setState(() {
          _statusRegister = "Usuário já registrado.";
        });
      } else if (email.isEmpty) {
        _emailFocusNode.requestFocus();
        setState(() {
          _statusRegister = "Preencha o campo email.";
        });
      } else if (password.isEmpty) {
        _passwordFocusNode.requestFocus();
        setState(() {
          _statusRegister = "Preencha o campo senha.";
        });
      } else if (passwordConfirmation.isEmpty) {
        _passwordConfirmationFocusNode.requestFocus();
        setState(() {
          _statusRegister = "Preencha o campo de confirmação de senha.";
        });
      } else if (password != passwordConfirmation) {
        _passwordConfirmationFocusNode.requestFocus();
        _controllerPasswordConfirmation.text = "";
        setState(() {
          _statusRegister = "Informe a mesma senha nos dois últimos campos.";
        });
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => Center(
            child: Container(
              height: 50,
              width: 50,
              color: Colors.transparent,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          _register();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Container(
                  width: 40,
                  height: 40,
                  child: FloatingActionButton(
                    heroTag: null,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    onPressed: _openLoginPage,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 10),
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget> [
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: "Digíte seu nome:"),
            style: TextStyle(fontSize: 22),
            controller: _controllerName,
            autofocus: true,
            focusNode: _nameFocusNode,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: "Digíte seu e-mail:"),
            style: TextStyle(fontSize: 22),
            controller: _controllerEmail,
            focusNode: _emailFocusNode,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: "Digíte sua senha:"),
            style: TextStyle(fontSize: 22),
            obscureText: true,
            maxLength: 8,
            controller: _controllerPassword,
            focusNode: _passwordFocusNode,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: "Confirme sua senha:"),
            style: TextStyle(fontSize: 22),
            obscureText: true,
            maxLength: 8,
            controller: _controllerPasswordConfirmation,
            focusNode: _passwordConfirmationFocusNode,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            //ignore: deprecated_member_use
            child:  RaisedButton(
              color: Colors.black,
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                "Cadastrar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: _checkFields,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              _statusRegister,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}