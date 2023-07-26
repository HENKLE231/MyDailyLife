import 'package:flutter/material.dart';
import 'package:my_daily_life/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryPage extends StatefulWidget {
  int pageNumber;
  List<String> titles = [];
  List<String> pages = [];
  DiaryPage({required this.pageNumber, required this.titles, required this.pages});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  TextEditingController _controllerPageContent = TextEditingController();
  IconData _saveButtonIcon = Icons.save;
  int _minLines = 1;
  int _userIndex = 0;

  void initState() {
    _loadPages();
    _controllerPageContent = TextEditingController(text: widget.pages[widget.pageNumber]);
    Future.delayed(const Duration(milliseconds: 1), () {
      _loadMinLines();
    });
  }
  
  void _loadMinLines() {
    double height = MediaQuery.of(context).size.height;
    setState(() {
      _minLines = ((height - 100) / 22).toInt();
    });
  }

  void _loadPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userIndex = prefs.getInt("_userIndex") ?? 0;
    widget.titles = prefs.getStringList("titles$_userIndex") ?? [];
    widget.pages = prefs.getStringList("pages$_userIndex") ?? [];
  }

  void _save() async {
    setState(() {
      _saveButtonIcon = Icons.done;
    });
    String pageContent = _controllerPageContent.text;

    List<String> sortedTitles = [];
    List<String> sortedPages = [];

    for (int i = 0; i < widget.titles.length; i++) {
      if (i != widget.pageNumber) {
        sortedTitles.add(widget.titles[i]);
        sortedPages.add(widget.pages[i]);
      }
    }
    sortedTitles.add(widget.titles[widget.pageNumber]);
    sortedPages.add(pageContent);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("titles$_userIndex", sortedTitles);
    prefs.setStringList("pages$_userIndex", sortedPages);

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _saveButtonIcon = Icons.save;
      });
    });
  }

  void _openHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
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
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    onPressed: _openHomePage,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 10),
                child: Text(
                  widget.titles[widget.pageNumber],
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
          TextFormField(
            autofocus: true,
            minLines: _minLines,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: _controllerPageContent,
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //SaveButton
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
                  _saveButtonIcon,
                  color: Colors.black,
                  size: 50,
                ),
                backgroundColor: Colors.white,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}