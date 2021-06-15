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
    final estado = new TextEditingController( );

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
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text("Nuevo"),
              content: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      nNombre.nombre = value;
                    },
                    decoration: InputDecoration(labelText: "NOMBRE:"),
                  ),
                  TextField(
                    onChanged: (value) {
                      nNombre.correo = value;
                    },
                    decoration: InputDecoration(labelText: "CORREO:"),
                  ),
                  TextField(
                    onChanged: (value) {
                      nNombre.celular = value;
                    },
                    decoration: InputDecoration(labelText: "celular:"),
                  ),
                ],
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                   bool i = await _databaseHelper.existe(nNombre.celular);
                  // print(i);

                   //print(i?_showAlert("EL NUMERO YA EXISTE"):"");
                    if(i==false){
                      _databaseHelper.insert(nNombre).then((value) {
                      
                       updateList();
                     });
                    }else{
                     // print("existe");
                         _showAlert("EL NUMERO YA EXISTE");
                    }
                  },
                )
              ],
            ),
          );
        });
  }
Widget _showAlert(String text){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("ERROR!!"),
          content: new Text(text),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    final controller = TextEditingController(text: nNombre.nombre);
    final correo = TextEditingController(text: nNombre.correo);
    final celular = TextEditingController(text: nNombre.celular);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Modificar"),
            content: Column(
              children: [
                TextField(
                  controller: controller,
                  onChanged: (value) {
                    nNombre.nombre = value;
                  },
                  decoration: InputDecoration(labelText: "nombre:"),
                ),
                TextField(
                  controller: correo,
                  onChanged: (value) {
                    nNombre.correo = value;
                  },
                  decoration: InputDecoration(labelText: "correo:"),
                ),
                TextField(
                  controller: celular,
                  onChanged: (value) {
                    nNombre.celular = value;
                  },
                  decoration: InputDecoration(labelText: "celular:"),
                ),
              ],
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
            return UsuariosWidget(
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

class UsuariosWidget extends StatelessWidget {
  final Usuario usuario;
  final OnDeleted onDeleted;
  final OnUpdate onUpdate;
  final int index;
  UsuariosWidget(this.usuario, this.onDeleted, this.index, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${usuario.id}"),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(),
            Expanded(
              child: Text(usuario.nombre  ),
            ),
            Expanded(
              child: Text(usuario.correo),
            ),
            Expanded(
              child: Text(usuario.celular),
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
