import 'package:sqflite/sqflite.dart';


abstract class TableElement{
  int id;
  final String tableName;
  TableElement(this.id, this.tableName);
  void createTable(Database db);
  Map<String, dynamic> toMap();
}

class Usuario extends TableElement{
  static final String TABLE_NAME = "usuario";
  String nombre;
  String correo;
  String celular;

  Usuario({this.nombre, id,this.correo,this.celular}):super(id, TABLE_NAME);
  factory Usuario.fromMap(Map<String, dynamic> map){
    return Usuario(nombre: map["nombre"], id: map["_id"],correo: map["correo"],celular:map["celular"]);
  }

  @override
  void createTable(Database db) {
    db.rawUpdate("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, nombre text ,correo text NOT NULL UNIQUE,celular text NOT NULL UNIQUE)");
  }

  @override
  Map<String, dynamic> toMap() {
   var map = <String, dynamic>{"nombre":this.nombre , "correo":this.correo,"celular":this.celular};
   if(this.id != null){
     map["_id"] = id;
   }
    return map;
  }

}


final String DB_FILE_NAME = "crub.db";

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database _database;


  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await open();

    return _database;
  }

  Future<Database> open() async {
    try{
      String databasesPath = await getDatabasesPath();
      String path = "$databasesPath/$DB_FILE_NAME";
      var db  = await openDatabase(path,
          version: 1,
          onCreate: (Database database, int version) {
              new Usuario().createTable(database);
          });
      return db;
    }catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<List<Usuario>> getList() async{
    Database dbClient = await db;

    List<Map> maps = await dbClient.query(Usuario.TABLE_NAME,
        columns: ["_id", "nombre","correo","celular"]);

    return maps.map((i)=> Usuario.fromMap(i)).toList();
  }
  Future<bool> existe(String celular ) async {
  var result = await _database.rawQuery(
    'SELECT EXISTS(SELECT 1 FROM usuario WHERE celular=$celular)',
  );
  int exists = Sqflite.firstIntValue(result);
  return exists == 1;
}

  Future<TableElement> insert(TableElement element) async {
    var dbClient = await db;

    element.id = await dbClient.insert(element.tableName, element.toMap());
    print(element.id==null?"errro":"registro exitoso");
    return element;
  }
  Future<int> delete(TableElement element) async {
    var dbClient = await db;
    return await dbClient.delete(element.tableName, where: '_id = ?', whereArgs: [element.id]);

  }
  Future<int> update(TableElement element) async {
    var dbClient = await db;

    return await dbClient.update(element.tableName, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}









