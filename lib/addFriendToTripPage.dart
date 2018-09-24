import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddFriendToTripPage extends StatefulWidget {
  Firestore db;
  DocumentSnapshot tripDocument;
  Widget header;
  FirebaseUser currentUser;
  AddFriendToTripPage(
      Firestore db, DocumentSnapshot tripDocument, FirebaseUser currentUser) {
    this.db = db;
    this.tripDocument = tripDocument;
    this.currentUser = currentUser;
  }

  @override
  State<StatefulWidget> createState() {
    return new AddFriendToTripPageState();
  }
}

class AddFriendToTripPageState extends State<AddFriendToTripPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Companions"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icons/friends.png",),
                fit: BoxFit.contain,
              )
            ),
            padding: EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Text(
                  "It's dangerous to go alone, gather some mates!",
                  style: Theme
                      .of(context)
                      .textTheme
                      .title
                      .copyWith(color: Colors.black),
                ),
                Expanded(
                  child: StreamBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: new Text('Loading...'));
                      else if (snapshot.data.documents.length == 0) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                                "Being a lone wolf is cool but some memories are priceless shared with people you love.",
                                textAlign: TextAlign.center,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                    child: Text("Call them!",
                                    style: new TextStyle(
                                      color:Colors.white
                                    )),
                                    onPressed: (){},
                                  ),
                                )
                          ],
                        );
                      }
                      return ListView(
                        children: snapshot.data.documents.map((document) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  document.data["image"]),
                            ),
                            title: Text(document.data["name"]),
                            trailing: RaisedButton(
                              child: Image.asset(
                                "assets/icons/comeFinger.png",
                                width: 45.0,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                print(context);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "A raven has been sent to " +
                                              document.data["name"] +
                                              "!"),
                                      backgroundColor: Colors.black,
                                      duration: Duration(
                                        seconds: 3
                                      ),
                                    ));
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                    stream: widget.db
                        .collection(
                            "users/" + widget.currentUser.uid + "/friends")
                        .snapshots(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
