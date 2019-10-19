import 'package:flutter/material.dart';
import 'dart:async';
import 'package:note_keeper/models/note.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';


class NoteDetail extends StatefulWidget{
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note,this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail>{
  static var _priorities = ['High','Low'];

  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  String appBarTitle;
  Note note;
  NoteDetailState(this.note,this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    desController.text = note.description;

    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0,left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            //1st element
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem){
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser){
                    setState(() {
                      debugPrint('User selectec $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }
              ),
            ),
            //2nd element
            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in title text field');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),
            //3rd element
            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: TextField(
                controller: desController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in desc text field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Descrption',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top:15.0,bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text('Save', textScaleFactor: 1.5,),
                      onPressed: (){
                        setState(() {
                          debugPrint('Save button');
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(width: 10.0,),
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text('Delete', textScaleFactor: 1.5,),
                      onPressed: (){
                        setState(() {
                          debugPrint('Delete button');
                          _delete();
                        });
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ) ,
    );
  }

  //convert the String priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value){
    String priority;
    switch (value){
      case 1 :
        priority = _priorities[0]; //High
        break;
      case 2 :
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

  //Update the title of NOte object
  void updateTitle(){
    note.title = titleController.text;
  }

  //Update the description of Note object
  void updateDescription(){
    note.description = desController.text;
  }

  //Save data to database
  void _save() async{
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != 0){//case 1 update operation
      result = await helper.updateNote(note);
    }else{//case 2 insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog('Status','Note Saved Successfully!');
    }else {
      _showAlertDialog('Status','Problem Saving Note');
    }
  }
  void _showAlertDialog(String title,String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  void _delete() async{

    moveToLastScreen();
      //case 1 if user is trying to delete the new note ex: he has come to the details page by pressing the fab of Notelist page
    if(note.id == null){
      _showAlertDialog('Status', 'No note was deleted');
      return;
    }
    //case 2 user is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully!');
    }else{
      _showAlertDialog('Status', 'Error Occured while Deleting note');
    }
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

}
