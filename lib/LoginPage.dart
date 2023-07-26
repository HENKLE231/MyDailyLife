import 'package:flutter/material.dart';
import 'package:my_daily_life/Home.dart';
import 'package:my_daily_life/RegisterPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_daily_life/firebase_db.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerUser = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  String _statusLogin = "";
  String _adminName = "admin";
  String _adminPassword = "231";
  late FocusNode _userFocusNode = FocusNode();
  late FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    _loadLastUser();
  }

  void _loadLastUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _controllerUser.text = prefs.getString("_lastUser") ?? "";
    if (_controllerUser.text == "") {
      _userFocusNode.requestFocus();
    } else {
      _passwordFocusNode.requestFocus();
    }
  }

  void _login() async {
    String _currentUser = _controllerUser.text.trim();
    String _currentPassword = _controllerPassword.text.trim();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // FirebaseDB db = FirebaseDB();//ALTERAR Fazer funcionar
    // db.loadAccountData();

    if (_currentUser.isEmpty) {
      _userFocusNode.requestFocus();
      setState(() {
        _statusLogin = "Preencha o campo nome.";
      });
    } else {
      _passwordFocusNode.requestFocus();
      if (_currentPassword.isEmpty) {
      setState(() {
        _statusLogin = "Preencha o campo senha.";
      });
      } else {
        List<String> _users = prefs.getStringList("users") ?? [];
        int _userIndex = _users.indexOf(_currentUser);
        String _allowedPassword = prefs.getString("password$_userIndex") ?? "";

        if (_userIndex < 0) {
          _userFocusNode.requestFocus();
          setState(() {
            _statusLogin = "Usuário não registrado.";
          });
        } else if (_currentPassword != _allowedPassword) {
          _passwordFocusNode.requestFocus();
          setState(() {
            _statusLogin = "Senha incorreta.";
          });
        } else {
          prefs.setString("_lastUser", _currentUser);
          prefs.setInt("_userIndex", _userIndex);
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          });
        }
      }
    }
  }

  void _openRegisterPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void _clearFields() {
    _controllerUser.text = "";
    _controllerPassword.text = "";
    setState(() {
      _statusLogin = "";
    });
  }

  void _clearMemoryConfirmation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Limpar memória",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Ao limpar a memória, dados não salvos na nuvem serão perdidos, tem certeza que deseja continuar?"
        ),
        actions: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 125,
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  //ignore: deprecated_member_use
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                    color: Colors.black,
                    child: Text(
                      "Sim",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _clearMemory,
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 125,
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  //ignore: deprecated_member_use
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                    color: Colors.black,
                    child: Text(
                      "Não",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _clearFields();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Limpeza de memória",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Limpeza efetuada com sucesso!!!",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      )
    );
    await Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      _userFocusNode.requestFocus();
    });
  }

  _getWidth() {
    return MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "My Daily Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget> [
          Image.asset(
            "../img/My_Daily_Life_Icon.png",
            height: 280,
          ),
          TextField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration(labelText: "Digíte seu nome:"),
            style: TextStyle(fontSize: 22),
            controller: _controllerUser,
            focusNode: _userFocusNode,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5, right: 2),
                child: Container(
                  width: _getWidth() / 2 - 25,
                  //ignore: deprecated_member_use
                  child: RaisedButton(
                    color: Colors.black,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(
                      "Logar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    onPressed: _login,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5, left: 2),
                child: Container(
                  width: _getWidth() / 2 - 25,
                  //ignore: deprecated_member_use
                  child: RaisedButton(
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
                    onPressed: _openRegisterPage,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              _statusLogin,
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
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Text(
                    "Limpar memória",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
              onTap: _clearMemoryConfirmation,
            ),
          ],
        ),
      ),
    );
  }
}