import 'package:flutter/material.dart';
import 'dart:async';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'note_details.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB Clicked');
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[index].priority),
              child: getPriorityIcon(this.noteList[index].priority),
            ),
            title: Text(
              this.noteList[index].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[index].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, noteList[index]);
              },
            ),
            onTap: () {
              debugPrint('ListTile Tapped');
              navigateToDetail(this.noteList[index], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Successfully");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }
  //
  // void updateListView() {
  //   Future<Database> dbFuture = databaseHelper.initializeDatabase();
  //   dbFuture.then((value) {
  //     Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
  //     noteListFuture.then((noteList) {
  //       setState(() {
  //         this.noteList = noteList;
  //         this.count = noteList.length;
  //       });
  //     });
  //   });
  // }

  void updateListView() async {
    Database dbFuture = await databaseHelper.initializeDatabase();
    List<Note> noteListFuture = await databaseHelper.getNoteList();
    setState(() {
      this.noteList = noteListFuture;
      this.count = noteListFuture.length;
    });
  }
}
