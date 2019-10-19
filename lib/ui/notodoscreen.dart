import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todoapp/model/nodoitem.dart';
import 'package:todoapp/util/database_client.dart';
import 'package:todoapp/util/date_formatter.dart';

class NotodoScreen extends StatefulWidget {
  @override
  _NotodoScreenState createState() => _NotodoScreenState();
}

class _NotodoScreenState extends State<NotodoScreen> {
  final TextEditingController _textEditingController = new TextEditingController();

    var db = new DatabaseHelper();
    final List<NoDoItem> itemList = <NoDoItem>[];


  @override
  void initState() {
    super.initState();

    _readNoDolist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,

      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(

              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: itemList.length,
              itemBuilder: (_, int index){
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: itemList[index],
                    onLongPress: () => _updateItem(itemList[index], index),
                    trailing: Listener(
                      key: Key(
                        itemList[index].itemName
                      ),
                      child: Icon(Icons.remove_circle,
                      color: Colors.redAccent,),
                      onPointerDown: (pointerEvent) => _deleteItem(itemList[index].id, index),//Finger has tapped the circle
                    ),
                  ),
                );
              },

            ),
          ),


          Divider(
            height: 1.0,
          )
        ],
      ),



      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        backgroundColor: Colors.blueAccent,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: () => _showFormDialog(),
      ),
    );
  }
















  _showFormDialog() {

    var alert = new AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg. Don't buy stuff",
                icon: Icon(Icons.note_add)
              ),
            ),
          )
        ],
      ),




      actions: <Widget>[

        FlatButton(
          onPressed: (){
            _handleSubmit(_textEditingController.text);
            _textEditingController.clear();

            Navigator.pop(context);
          },
          child: Text("Save"),
        ),

        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );

    showDialog(context: context, builder: (_){
      return alert;
    });
  }



  void _handleSubmit(String text) async{
      _textEditingController.clear();

      NoDoItem noDoItem = new NoDoItem(text, dateFormatted());
      int savedItemId = await db.saveItem(noDoItem);

      NoDoItem addedItem = await db.getItem(savedItemId);


      setState(() {
        itemList.insert(0, addedItem);
//        itemList.add(addedItem);

      });

      print("Item saved id: $savedItemId");
  }



  _readNoDolist() async{
    List items = await db.getAllItems();
    items.forEach((item){
//      NoDoItem noDoItem = NoDoItem.map(item);
//      print("Db Items: ${noDoItem.itemName}");

    //Very important method,  We want to redraw our screen
      setState(() {
        itemList.add(NoDoItem.map(item));
      });

    });

  }

  _deleteItem(int id, int index) async {
    debugPrint("Deleted Item:!");

    await db.deleteItem(id);

    //We want to redraw our screen
    setState(() {
      itemList.removeAt(index);
    });


  }

  _updateItem(NoDoItem noDoItem, int index) {
//    debugPrint("Updated Item");

    var alert  = new AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[

          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg. Don't buy stuff",
                icon: Icon(Icons.update)
              ),
            ),
          )
        ],
      ),

      actions: <Widget>[

        FlatButton(
          onPressed: () async{
//            debugPrint("Update");
              NoDoItem newUpdatedItem = NoDoItem.fromMap({
                "itemName" : _textEditingController.text,
                "dateCreated" : dateFormatted(),
                "id" : noDoItem.id
              });

              _handleSubmittedUpdate(index, noDoItem);
              await db.updateItem(newUpdatedItem);

              setState(() {
                _readNoDolist();
              });

              Navigator.pop(context);
          },

          child: Text("Update"),
        ),

        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );

    showDialog(context: context, builder: (_){
      return alert;
    });

  }

  void _handleSubmittedUpdate(int index, NoDoItem noDoItem) {
    setState(() {

      itemList.removeWhere((element){

        return itemList[index].itemName == noDoItem.itemName;
      });


    });

  }
}
