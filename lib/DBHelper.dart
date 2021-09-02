import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/wordpair.dart';
import '../../models/wordpairs.dart';

class DBHelper {
  static Database? _db;
  // Create the Table colums
  static const String TABLE1 = 'et';
  static const String TABLE2 = 'te';
  static const String TABLE3 = 'ce';
  static const String ID = 'id';
  static const String EN = 'en';
  static const String TH = 'th';
  static const String DB_NAME = 'dic.db';


  // Initialize the Database
  Future<Database> get db async =>
      _db ??= await initDb();

  initDb() async {
    // Get the Device's Documents directory to store the Offline Database...
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    // Create the DB Table
    await db.execute(
        "CREATE TABLE $TABLE1 (ID INTEGER PRIMARY KEY, $EN TEXT, $TH TEXT)");
    print('create table $TABLE1');
    await db.execute(
        "CREATE TABLE $TABLE2 (ID INTEGER PRIMARY KEY, $EN TEXT, $TH TEXT)");
    print('create table $TABLE2');
    await db.execute(
        "CREATE TABLE $TABLE3 (ID INTEGER PRIMARY KEY, $EN TEXT, $TH TEXT)");
    print('create table $TABLE3');
  }
   String gettable(int cnt) {
     String table='';
     if (cnt==1){
       table=TABLE1;
     }
     else if (cnt==2) {
        table=TABLE2;
     }
     else if (cnt==3) {
       table=TABLE3;
     }
     return table;
   }

  Future <void> deleteDB() async {
  io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, DB_NAME);
  // Delete the database
  print('drop database...... ');
  print(path);
  print(databaseExists(path));
   bool isExist =await databaseExists(path);
  if (isExist==true) {
    print('exists');
    await deleteDatabase(path);
  }
}

  Future<bool> tableIsEmpty(int cnt) async{

    var dbclient = await db;
    String table=gettable(cnt);
    print(table);
    int count=0;
    List<Map> result= await dbclient.rawQuery('SELECT COUNT(*) as cnt FROM $table');
    result.forEach((dbItem) {
      count = dbItem["cnt"];
      print(count);
    }
    );
print('count ---- ');
print(count);
    bool isEmpty;
    if (count==0) {
      isEmpty = true;
    }
    else {
      isEmpty = false;
    }
    print(isEmpty);
    return isEmpty;
  }

  // Method to insert the Album record to the Database
  Future<int> save(int cnt,Wordpair wp) async {
    var dbClient = await db;
    String table=gettable(cnt);
    // this will insert the Album object to the DB after converting it to a json
    int idInserted=await dbClient.insert(table, wp.toJson());
    print(table);
    return idInserted;
  }

  // Method to return all Albums from the DB
  Future insertChineseOnePair(List<String>  wp) async{
    var dbClient = await db;
    await dbClient.rawInsert('insert into ce (en,th) values (?,?)',wp);
  }

  Future<Wordpairs> getWordpairs(int cnt) async {
    var dbClient = await db;
    String table=gettable(cnt);
    // specify the column names you want in the result set
    List<Map<String, dynamic>> maps =
    await dbClient.query(table, columns: [ID, EN, TH]);
    List<Wordpair> wps = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        wps.add(Wordpair.fromJson(maps[i]));
      }
    }
    Wordpairs allwps = Wordpairs(wordpairs:wps);
    return allwps;
  }

  // Method to delete an Album from the Database
  Future<int> delete(int cnt,int id) async {
    var dbClient = await db;
    String table=gettable(cnt);
    return await dbClient.delete(table, where: '$ID = ?', whereArgs: [id]);
  }

  // Method to Update an Album in the Database
  Future<int> update(int cnt,Wordpair wp) async {
    var dbClient = await db;
    String table=gettable(cnt);
    return await dbClient
        .update(table, wp.toJson(), where: '$EN = ?', whereArgs: [wp.en]);
  }

  // Method to Truncate the Table
  Future<int> truncateTable(int cnt) async {
    String table=gettable(cnt);
    var dbClient = await db;
    int count=0;
    List<Map> result= await dbClient.rawQuery('select count(*) as cnt from sqlite_master where name=?', [table]) ;
    result.forEach((dbItem) {
      count = dbItem["cnt"];
    }
    );
    if  (count!=0) {
      return await dbClient.delete(table);
    }
    else {
      return -1;
    }
  }

  // Method to Close the Database
  Future close() async {
    var dbClient = await db;
    _db=null;
    dbClient.close();
  }
}