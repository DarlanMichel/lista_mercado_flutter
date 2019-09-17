import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];

  /*List<DropdownMenuItem<String>> grupo = [];
  String selected = null;
  void loadData(){
    grupo = [];
    grupo.add(new DropdownMenuItem(
        child: new Text("Padaria"),
        //value: 1,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Frutas/Verduras"),
      //value: 2,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Açogue"),
      //value: 3,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Bebidas"),
      //value: 4,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Limpeza"),
      //value: 5,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Doces"),
      //value: 6,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Grãos"),
      //value: 7,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Frios"),
      //value: 8,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Ravena"),
      //value: 9,
    ));
    grupo.add(new DropdownMenuItem(
      child: new Text("Outros"),
      //value: 10,
    ));
  }*/


  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      newToDo["grupo"] = selected;
      selected = null;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    //loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Novo Produto",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    items: grupo,
                    hint:  Text("Selecione um Grupo..."),
                    onChanged: (value){
                      selected = value;
                      setState(() {

                      });
                    },
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Adicionar"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Produto \"${_lastRemoved["title"]}\" removido!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
