import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageList extends StatefulWidget {
  FirebaseStorage storage;
  DocumentSnapshot tripDocument;
  FirebaseUser currentUser;
  ScrollController scrollController;
  Firestore db;
  MessageList(
      Firestore db,
      FirebaseUser currentUser,
      DocumentSnapshot tripDocument,
      FirebaseStorage storage,
      ScrollController scrollController) {
    this.currentUser = currentUser;
    this.db = db;
    this.scrollController = scrollController;
    this.tripDocument = tripDocument;
    this.storage = storage;
  }

  @override
  MessageListState createState() {
    return new MessageListState();
  }
}

class MessageListState extends State<MessageList> {
  TextDirection getTextDirection(DocumentSnapshot document) {
    if (document["uid"] == widget.currentUser.uid)
      return TextDirection.rtl;
    else
      return TextDirection.ltr;
  }

  CrossAxisAlignment getCrossAlignment(DocumentSnapshot document) {
    if (document["uid"] == widget.currentUser.uid)
      return CrossAxisAlignment.end;
    else
      return CrossAxisAlignment.start;
  }

  void addNewMessage(String text) {
    widget.db
        .collection(widget.tripDocument.reference.path + "/messages")
        .add(
      {
        "sender": widget.currentUser.displayName,
        "content": text,
        "time": DateTime.now().toString(),
        "uid": widget.currentUser.uid,
        "photoUrl": widget.currentUser.photoUrl,
      },
    ).then((value) {
      widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent,
          curve: Curves.ease, duration: new Duration(milliseconds: 300));
    });
  }

  Future<String> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    final StorageReference ref = widget.storage
        .ref()
        .child('images')
        .child(widget.currentUser.uid)
        .child((new DateTime.now().toString() + '.jpg'));
    final StorageUploadTask uploadTask = ref.putFile(
      image,
      new StorageMetadata(
        contentLanguage: 'vi',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    var url = (await uploadTask.future).downloadUrl;
    return url.toString();
  }

  @override
  void initState() {
    widget.db.collection(widget.tripDocument.reference.path+'/messages').snapshots().listen((onData){
      widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent+100,curve: Curves.ease, duration: Duration(milliseconds: 300));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget getContent(DocumentSnapshot document) {
      int index = document["content"].indexOf('http');
      if (index >= 0) {
        return new CachedNetworkImage(
          placeholder: new Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: new AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          imageUrl: document["content"].toString().trimRight(),
        );
      } else
        return new Text(
          document["content"],
          style: Theme.of(context).textTheme.body1,
          //textDirection: getTextDirection(document),
          textDirection: TextDirection.ltr,
        );
    }

    Color getBackGroundColor(DocumentSnapshot document) {
      if (document["uid"] == widget.currentUser.uid)
        return Theme.of(context).backgroundColor;
      else
        return Color.fromRGBO(0, 0, 0, 0.05);
    }

    TextEditingController textEditingController = new TextEditingController();

    return new Column(
      children: <Widget>[
        new Container(
          child: new Expanded(
            child: new StreamBuilder(
              stream: widget.db
                  .collection(
                      this.widget.tripDocument.reference.path + "/messages")
                  .orderBy("time")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');
                ListView listView = new ListView(
                  padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                  controller: widget.scrollController,
                  scrollDirection: Axis.vertical,
                  children: snapshot.data.documents.map((document) {
                    return new Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: new ListTile(
                          title: new Row(
                        textDirection: getTextDirection(document),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                            child: widget.currentUser.uid != document["uid"]
                                ? new Container(
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: new CachedNetworkImageProvider(
                                              document["photoUrl"])),
                                    ),
                                    width: 50.0,
                                    height: 50.0,
                                  )
                                : null,
                          ),
                          new Expanded(
                              child: new Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: new Column(
                              crossAxisAlignment: getCrossAlignment(document),
                              children: <Widget>[
                                new Container(
                                  constraints: new BoxConstraints(
                                    maxWidth: 200.0,
                                  ),
                                  padding: new EdgeInsets.all(10.0),
                                  decoration: new BoxDecoration(
                                      color: getBackGroundColor(document),
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(10.0))),
                                  child: getContent(document),
                                )
                              ],
                            ),
                          )),
                        ],
                      )),
                    );
                  }).toList(),
                );
                return listView;
              },
            ),
          ),
        ),
        new Container(
          alignment: Alignment.bottomCenter,
          child: new TextField(
            controller: textEditingController,
            decoration: new InputDecoration(
              prefixIcon: new IconButton(
                icon: new Icon(Icons.camera),
                onPressed: () async {
                  addNewMessage(await getImage());
                },
              ),
              suffixIcon: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () async {
                  if (textEditingController.text.length > 0) {
                    addNewMessage(textEditingController.text);
                    textEditingController.clear();
                  }
                },
              ),
              hintText: "Say something...",
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (String text) {
              addNewMessage(text);
            },
            onChanged: (text) {
              if (text.indexOf('http') >= 0) {
                try {
                  CachedNetworkImage(
                    imageUrl: text,
                  );
                  addNewMessage(text);
                  textEditingController.clear();
                } catch (ex) {}
              }
            },
          ),
        )
      ],
    );
  }
}
