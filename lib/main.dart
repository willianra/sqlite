import 'package:flutter/material.dart';

import 'database.dart';

final String DB_NAME = "usuarios";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAREA TOPICOS',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  List<Usuario> _list;
  DatabaseHelper _databaseHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        centerTitle: true,
        title: Text("tarea topicos"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              insert(context);
            },
          )
        ],
      ),
      body: _getBody(),
    );
  }

  void insert(BuildContext context) {
    Usuario nNombre = new Usuario();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Nuevo"),
            content: TextField(
              onChanged: (value) {
                nNombre.title = value;
              },
              decoration: InputDecoration(labelText: "Título:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Guardar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.insert(nNombre).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  void onDeletedRequest(int index) {
    Usuario usuario = _list[index];
    _databaseHelper.delete(usuario).then((value) {
      setState(() {
        _list.removeAt(index);
      });
    });
  }

  void onUpdateRequest(int index) {
    Usuario nNombre = _list[index];
    final controller = TextEditingController(text: nNombre.title);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Modificar"),
            content: TextField(
              controller: controller,
              onChanged: (value) {
                nNombre.title = value;
              },
              decoration: InputDecoration(labelText: "Título:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Actualizar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.update(nNombre).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  Widget _getBody() {
    if (_list == null) {
      return CircularProgressIndicator();
    } else if (_list.length == 0) {
      return Text("Está vacío");
    } else {
      return ListView.builder(
          itemCount: _list.length,
          itemBuilder: (BuildContext context, index) {
            Usuario usuario = _list[index];
            return CiudadWidget(
                usuario, onDeletedRequest, index, onUpdateRequest);
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
    updateList();
  }

  void updateList() {
    _databaseHelper.getList().then((resultList) {
      setState(() {
        _list = resultList;
      });
    });
  }
}

typedef OnDeleted = void Function(int index);
typedef OnUpdate = void Function(int index);

class CiudadWidget extends StatelessWidget {
  final Usuario usuario;
  final OnDeleted onDeleted;
  final OnUpdate onUpdate;
  final int index;
  CiudadWidget(this.usuario, this.onDeleted, this.index, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${usuario.id}"),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(usuario.title),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 30,
              ),
              onPressed: () {
                this.onUpdate(index);
              },
            )
          ],
        ),
      ),
      onDismissed: (direction) {
        onDeleted(this.index);
      },
    );
  }
}
