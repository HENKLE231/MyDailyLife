import 'package:flutter/material.dart';
import 'package:my_daily_life/DiaryPage.dart';
import 'package:my_daily_life/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:my_daily_life/firebase_db.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controllerNewPageTitle = TextEditingController();
  TextEditingController _controllerNewTitle = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  int _selectedPageAction = 0; // 0: Open, 1: Edit, 2: Delete
  String _appBarText = "My Daily Life";
  Color _addButtonBackgroundColor = Colors.white;
  Color _editButtonBackgroundColor = Colors.white;
  Color _deleteButtonBackgroundColor = Colors.white;
  String _name = "";
  String _email = "";
  int _userIndex = 0;
  List<String> _titles = [];
  List<String> _pages = [];

  void yetToBeBuilt(String function) { //APAGAR DPS
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Função incompleta",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "A função $function, ainda não foi desenvolvida.",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      )
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void initState() {
    _loadPages();
    Future.delayed(const Duration(milliseconds: 1), () {
      setState(() {
        _showPages();
      });
    });
  }

  void _loadPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userIndex = prefs.getInt("_userIndex") ?? 0;
    _name = prefs.getString("name$_userIndex") ?? "";
    _email = prefs.getString("email$_userIndex") ?? "";
    _titles = prefs.getStringList("titles$_userIndex") ?? [];
    _pages = prefs.getStringList("pages$_userIndex") ?? [];
  }

  String _checkAvailability(String newPageTitle) {
    String initialNewPageTitle = newPageTitle;

    bool acceptedTitle = false;
    int attemptcounter = 1;
    while (!acceptedTitle) {
      bool titleUsed = false;
      for (int i = 0; i < _titles.length; i ++) {
        if (_titles[i] == newPageTitle) {
          titleUsed = true;
        }
      }
      if (titleUsed) {
        attemptcounter++;
        newPageTitle = initialNewPageTitle + "(" + attemptcounter.toString() + ")";
      } else {
        acceptedTitle = true;
      }
    }
    return newPageTitle;
  }

  void _createNewPage() async {
    String newPageTitle = _controllerNewPageTitle.text.trim();
    _controllerNewPageTitle.text = "";
    if (newPageTitle.isEmpty) {
      newPageTitle = _getDate();
    }
    newPageTitle = _checkAvailability(newPageTitle);
    _titles.add(newPageTitle);
    _pages.add("");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("titles$_userIndex", _titles);
    prefs.setStringList("pages$_userIndex", _pages);

    setState(() {
      _showPages();
    });

    _openPage(_titles.length - 1);
  }

  String _getDate() {
    String date = DateTime.now().toString();
    String formattedDate = "Dia ";
    formattedDate += date.substring(8, 10) + "/"; //Dia
    formattedDate += date.substring(5, 7) + "/";  //Mês
    formattedDate += date.substring(0, 4);        //Ano
    return formattedDate;
  }
  
  List<Widget> _showPages() {
    _loadPages();
    List<Widget> pages = <Widget>[];
    for (int i = _titles.length - 1; i >= 0; i--) {
      pages.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          //ignore: deprecated_member_use
          child: RaisedButton(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              _titles[i],
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.left,
            ),
            onPressed: () {
              _selectPage(i);
            }
          ),
        )
      );
    }
    return pages;
  }

  void _openPage(int page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiaryPage(pageNumber: page, titles: _titles, pages: _pages)),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _selectPage(int page) {
    if (_selectedPageAction == 0) {
      _openPage(page);
    } else if (_selectedPageAction == 1) {
      _askForNewTitle(page);
    } else {
      _deletePageConfirmation(page);
    }
  }

  void _changeSelectedPageAction(int action) {
    _selectedPageAction = action;
    if (_selectedPageAction == 0) {
      _editButtonBackgroundColor = Colors.white;
      _deleteButtonBackgroundColor = Colors.white;
      setState(() {
        _appBarText = "My Daily Life";
      });
    } else if (_selectedPageAction == 1) {
      _deleteButtonBackgroundColor = Colors.white;
      _editButtonBackgroundColor = Colors.grey;
      setState(() {
        _appBarText = "Modo edição";
      });
    } else if (_selectedPageAction == 2) {
      _editButtonBackgroundColor = Colors.white;
      _deleteButtonBackgroundColor = Colors.grey;
      setState(() {
        _appBarText = "Modo exclusão";
      });
    }
  }

  void _askForNewTitle(int page) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Informe um novo título para a página:",
          textAlign: TextAlign.center,
        ),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 22),
          decoration: InputDecoration(hintText: _titles[page]),
          maxLength: 18,
          controller: _controllerNewTitle,
        ),
        actions: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 130,
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  //ignore: deprecated_member_use
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                    color: Colors.black,
                    child: Text(
                      "Renomear",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _editTitle(page);
                      Navigator.pop(context);
                    }
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 120,
                child: Padding(
                  padding: EdgeInsets.only(right: 2),
                  //ignore: deprecated_member_use
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                    color: Colors.black,
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _changeSelectedPageAction(0);
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

  void _editTitle(int page) async {
    String newPageTitle = _controllerNewTitle.text.trim();
    _controllerNewTitle.text = "";
    if (newPageTitle.isNotEmpty) {
      newPageTitle = _checkAvailability(newPageTitle);
      _titles[page] = newPageTitle;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("titles$_userIndex", _titles);

      setState(() {
        _showPages();
      });
    }

    _changeSelectedPageAction(0);
  }

  void _deletePageConfirmation(int page) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Exclusão de página",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Tem certeza?",
          textAlign: TextAlign.center,
        ),
        actions: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 100,
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
                    onPressed: () {
                      _deletePage(page);
                      Navigator.pop(context);
                    }
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 100,
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
                      _changeSelectedPageAction(0);
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

  void _deletePage(int page) async {
    _titles.removeAt(page);
    _pages.removeAt(page);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("titles$_userIndex", _titles);
    prefs.setStringList("pages$_userIndex", _pages);

    _changeSelectedPageAction(0);
  }

  void _deleteAccountConfirmation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Exclusão de conta",
          textAlign: TextAlign.center,
        ),
        content: TextField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(labelText: "Digíte sua senha:"),
          style: TextStyle(fontSize: 22),
          obscureText: true,
          maxLength: 8,
          controller: _controllerPassword,
          autofocus: true,
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
                      "Excluir",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _deleteAccount,
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
                      "Cancelar",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
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

  void _deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _allowedPassword = prefs.getString("password$_userIndex") ?? "";
    String _password = _controllerPassword.text.trim();
    _controllerPassword.text = "";

    if (_password == "") {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            "Falha ao excluir",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Campo senha em branco",
            textAlign: TextAlign.center,
          ),
        )
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else if (_password == _allowedPassword) {
      // FirebaseDB db = FirebaseDB();
      // db.deleteAccount();
      
      //Reorganizar as informações ja atribuidas
      List<String> users = prefs.getStringList('users') ?? [];
      String name;
      String email;
      String password;
      List<String> titles;
      List<String> pages;
      for (int i = _userIndex; i < users.length - 1; i ++) { 
        name = prefs.getString("name${i+1}") ?? "";
        email = prefs.getString("email${i+1}") ?? "";
        password = prefs.getString("password${i+1}") ?? "";
        titles = prefs.getStringList("titles${i+1}") ?? [];
        pages = prefs.getStringList("pages${i+1}") ?? [];
        
        prefs.setString("name$i", name);
        prefs.setString("email$i", email);
        prefs.setString("password$i", password);
        prefs.setStringList("titles$i", titles);
        prefs.setStringList("pages$i", pages);
      }
      //Retirar ultimo do cadastro (que ficou repetido)
      prefs.remove("name${users.length}");
      prefs.remove("email${users.length}");
      prefs.remove("password${users.length}");
      prefs.remove("titles${users.length}");
      prefs.remove("pages${users.length}");
      users.removeAt(_userIndex);
      prefs.setStringList("users", users);
      prefs.remove("_lastUser");
      
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            "Exclusão de conta",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Conta excluida com sucesso!!!",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        )
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage())
        );
      });
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            "Falha ao excluir",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Senha incorreta",
            textAlign: TextAlign.center,
          ),
        )
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  void _uploadToCloudConfirmation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Salvar na nuvem",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Tem certeza?"
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
                    onPressed: () {
                      yetToBeBuilt("Salvar na nuvem");
                      // FirebaseDB db = FirebaseDB();//ALTERAR Fazer funcionar
                      // db.save();
                    },
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

  void _downloadFromCloudConfirmation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          "Baixar da nuvem",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Tem certeza?"
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
                    onPressed: () {
                      yetToBeBuilt("Baixar da nuvem");
                      // FirebaseDB db = FirebaseDB(); //ALTERAR Fazer funcionar
                      // db.loadAccountData();
                    },
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
                        Icons.logout,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    onPressed: _logout,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 10),
                child: Text(
                  _appBarText,
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
        children: _showPages(),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //AddButton
          Padding(
            padding: EdgeInsets.only(right: 5, bottom: 5, left: 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 9,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(100)
                ),
              ),
              child: FloatingActionButton(
                heroTag: null,
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 50,
                ),
                backgroundColor: _addButtonBackgroundColor,
                onPressed: () {
                  _changeSelectedPageAction(0);
                  setState(() {
                    _addButtonBackgroundColor = Colors.grey;
                  });
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        "Informe um título para a nova página:",
                        textAlign: TextAlign.center,
                      ),
                      content: TextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 22),
                        decoration: InputDecoration(hintText: _getDate()),
                        maxLength: 18,
                        controller: _controllerNewPageTitle,
                      ),
                      actions: <Widget> [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 40,
                              width: 130,
                              child: Padding(
                                padding: EdgeInsets.only(right: 2),
                                //ignore: deprecated_member_use
                                child: RaisedButton(
                                  padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                                  color: Colors.black,
                                  child: Text(
                                    "Criar",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: _createNewPage,
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 120,
                              child: Padding(
                                padding: EdgeInsets.only(right: 2),
                                //ignore: deprecated_member_use
                                child: RaisedButton(
                                  padding: EdgeInsets.only(top: 10, right: 25, bottom: 10, left: 25),
                                  color: Colors.black,
                                  child: Text(
                                    "Cancelar",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _addButtonBackgroundColor = Colors.white;
                                    });
                                  }
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          //EditingButton
          Padding(
            padding: EdgeInsets.only(right: 5, bottom: 5, left: 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 9,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(100)
                ),
              ),
              child: FloatingActionButton(
                heroTag: null,
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 50,
                ),
                backgroundColor: _editButtonBackgroundColor,
                onPressed: () {
                  if (_selectedPageAction != 1) {
                    _changeSelectedPageAction(1);
                  } else {
                    _changeSelectedPageAction(0);
                  }
                }
              ),
            ),
          ),

          //DeleteButton
          Padding(
            padding: EdgeInsets.only(right: 5, bottom: 5, left: 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 9,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(100)
                ),
              ),
              child: FloatingActionButton(
                heroTag: null,
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 50,
                ),
                backgroundColor: _deleteButtonBackgroundColor,
                onPressed: () {
                  if(_selectedPageAction != 2) {
                    _changeSelectedPageAction(2);
                  } else {
                    _changeSelectedPageAction(0);
                  }
                }
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_name),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  _name.substring(0, 1),
                  style: TextStyle(fontSize: 40),
                ),
                backgroundColor: Colors.grey[850],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 30,
                    ),
                  ),
                  Text(
                    "Salvar na nuvem",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              onTap: _uploadToCloudConfirmation,
            ),
            ListTile(
              title: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.cloud_download_outlined,
                      size: 30,
                    ),
                  ),
                  Text(
                    "Baixar da nuvem",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              onTap: _downloadFromCloudConfirmation,
            ),
            Divider(),
            ListTile(
              title: Text(
                "Excluir conta",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                ),
              ),
              onTap: _deleteAccountConfirmation,
            ),
          ],
        ),
      ),
    );
  }
}