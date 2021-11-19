import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._creaeInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._creaeInstance();
    }
    return _databaseHelper;
  }

  Future<Database> database() async {
    if (_database == null) {
      print('database:$database');
      _database = await initializeDatabase();
    }else{

      print('database1:$_database');
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _creatDb);
    return notesDatabase;
  }

  Future _creatDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)");
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database();

    // var result = await db.rawQuery("SELECT * FROM $noteTable order by$colPriority ASC");
    var result = await db.query(noteTable, orderBy: " $colPriority ASC");
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await database();
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await database();
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    var db = await database();
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  Future<int> getNote() async {
    Database db = await database();
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
