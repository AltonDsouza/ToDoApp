
//Singleton Design pattern
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:todoapp/model/nodoitem.dart';

class DatabaseHelper{

  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableUser = "nodoTable";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }

    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();//contructors that are private to the class




  initDb() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notodo_db.db");//home://directory/files/maindb.db

    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate );
    return ourDb;
  }


  /*
  id | username | password
  ___________________________
  1  | Alton    | 123
  2  | James    | 123
   */
  void _onCreate(Database db, int version) async{
    //Create table
    await db.execute(
        "CREATE TABLE $tableUser($columnId INTEGER PRIMARY KEY, "
            "$columnItemName TEXT, $columnDateCreated TEXT)"

    );
  }

  //CRUD - CREATE READ UPDATE DELETE

  //Insertion
  Future<int> saveItem(NoDoItem item) async{

    var dbClient = await db;
    int res = await dbClient.insert(tableUser, item.toMap());

    return res;
  }


  //Get All Users
  Future<List> getAllItems() async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableUser ORDER "
        "BY $columnItemName ASC");

    return result.toList();//returns a list

  }


  //Count
  Future<int> getCount() async{

    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableUser")
    );
  }


  //Get Single User
  Future<NoDoItem> getItem(int id) async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableUser WHERE $columnId = $id");

    if(result.length == 0) return null;
    return NoDoItem.fromMap(result.first);

  }


  //Delete
  Future<int> deleteItem(int id) async{
    var dbClient = await db;

    return await dbClient.delete(tableUser,
        where: "$columnId = ?", whereArgs:  [id]);

  }


  //Update
  Future<int> updateItem(NoDoItem item) async{
    var dbClient = await db;

    return await dbClient.update(tableUser,
        item.toMap(), where: "$columnId = ?", whereArgs: [item.id]);
  }



  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }


}