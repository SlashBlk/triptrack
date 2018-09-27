import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:triptrack/addFriendToTripPage.dart';
import 'package:triptrack/destination.dart';
import 'package:triptrack/messageList.dart';
import 'package:triptrack/utility.dart';

class TripPage extends StatefulWidget {
  FirebaseStorage storage;
  Firestore db;
  DocumentSnapshot tripDocument;
  Widget header;
  FirebaseUser currentUser;
  TripPageHeader tripPageHeader;
  TripPage({
    @required this.currentUser,
    @required this.db,
    @required this.tripDocument,
    @required this.storage,
  });

  @override
  State<StatefulWidget> createState() {
    return new TripPageState();
  }
}

class TripPageState extends State<TripPage> {
  var initiateHeight = 230.0;
  var headerHeight = 230.0;
  int tabIdex = 0;
  var pointerPosition = new Offset(0.0, 0.0);
  TripPageState() {}
  @override
  Widget build(BuildContext context) {
    ScrollController imagesController = new ScrollController();
    ScrollController destinationsController = new ScrollController();
    ScrollController chatsController = new ScrollController();
    var controllers = [
      imagesController,
      destinationsController,
      chatsController
    ];
    controllers.forEach((controller) {
      controller.addListener(() {
        // if (controller.positions.last.userScrollDirection ==
        //         ScrollDirection.forward &&
        //     headerHeight == 0.0)
        //   setState(() {
        //     headerHeight = initiateHeight;
        //   });
        if (controller.positions.last.userScrollDirection ==
                ScrollDirection.reverse &&
            headerHeight == initiateHeight) {
          headerHeight = 0.0;
          setState(() {});
        }
      });
    });
    widget.tripPageHeader = new TripPageHeader(
      headerHeight: headerHeight,
      document: widget.tripDocument,
    );

    var destinationPage = new TabPage(
      key: new Key("2"),
      opacity: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new StreamBuilder(
          stream: widget.db
              .document(widget.tripDocument.reference.path)
              .collection("destinations")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(child: new CircularProgressIndicator());
            if (snapshot.data.documents.length == 0)
              return Center(
                  child: new Text(
                "Chưa có điểm đến",
                style: new TextStyle(color: Colors.grey),
              ));
            return new ListView(
                controller: destinationsController,
                children: snapshot.data.documents.map((destination) {
                  return new Destination(
                    checked: destination["visited"],
                    name: destination["name"],
                    description: destination["description"],
                    icon: new Icon(Icons.home),
                    onchangedHandle: () {
                      widget.db
                          .document(destination.reference.path)
                          .updateData({"visited": !destination["visited"]});
                    },
                  );
                }).toList());
          },
        ),
        // child: new ListView(
        //   children: <Widget>[
        //     new Destination(
        //       checked: true,
        //       title: "Yolo Hostel",
        //       description: "Điểm dừng chân",
        //       icon: new Icon(Icons.home),
        //     ),
        //     new Destination(
        //       checked: true,
        //       title: "Lang Biang",
        //       description: "Thắng cảnh",
        //       icon: new Icon(Icons.landscape),
        //     ),
        //     new Destination(
        //       checked: true,
        //       title: "Chợ đêm Đà Lạt",
        //       description: "Mua sắm",
        //       icon: new Icon(Icons.local_mall),
        //     ),
        //   ],
        // ),
      ),
    );
    var chatPage = new TabPage(
      key: new Key("3"),
      opacity: 0.0,
      child: new MessageList(widget.db, widget.currentUser, widget.tripDocument,
          widget.storage, chatsController),
    );
    var photoPage = new TabPage(
      key: new Key("1"),
      opacity: 0.0,
      child: new StreamBuilder(
        stream: widget.db
            .collection(widget.tripDocument.reference.path + "/images")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Center(
              child: new CircularProgressIndicator(),
            );
          if (snapshot.data.documents.length == 0)
            return new Center(
              child: new Text(
                "Chưa có hình!",
                style: new TextStyle(
                  color: Colors.grey,
                ),
              ),
            );

          var listView = new TripImages(
            controller: imagesController,
            snapshot: snapshot,
          );
          return listView;
        },
      ),
    );
    var friendsPage = new TabPage(
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Nguyen Xuan Nhi"),
              ),
            ],
          ),
          Positioned(
            bottom: 15.0,
            right: 16.0,
            child: FloatingActionButton(
              child: Icon(Icons.person_add),
              onPressed: () async {
                Navigator.push(
                    context,
                    Utility.customPageRouteBuilder(new AddFriendToTripPage(
                        widget.db, widget.tripDocument, widget.currentUser)));
              },
            ),
          ),
        ],
      ),
      opacity: 0.0,
      key: new Key("4"),
    );
    var pages = [photoPage, destinationPage, chatPage, friendsPage];
    var page = pages[tabIdex];
    var pagesLength = pages.length - 1;
    pages.removeAt(tabIdex);
    pages.insert(pagesLength, page);
    pages[pagesLength].opacity = 1.0;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "TripTrack",
        ),
        centerTitle: true,
        leading: new IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: new Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: new Column(
        children: <Widget>[
          GestureDetector(
            onVerticalDragEnd: (detail) {
              if (detail.velocity.pixelsPerSecond.direction > 0.0) {
                setState(() {
                  headerHeight = initiateHeight;
                });
              }
              if (detail.velocity.pixelsPerSecond.direction < 0) {
                setState(() {
                  headerHeight = 0.0;
                });
              }
            },
            child: widget.tripPageHeader,
          ),
          new Expanded(
            child: new GestureDetector(
              onHorizontalDragEnd: (detail) {
                if (detail.primaryVelocity < 0) {
                  if (!(tabIdex == 3))
                    tabIdex++;
                  else
                    tabIdex = 0;
                  setState(() {});
                }
                if (detail.primaryVelocity > 0) {
                  if (!(tabIdex == 0))
                    tabIdex--;
                  else
                    tabIdex = 3;
                  setState(() {});
                }
              },
              child: new Stack(
                children: pages,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: tabIdex,
        onTap: (index) {
          tabIdex = index;
          setState(() {
            tabIdex = index;
          });
        },
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.photo_album),
            title: new Text(
              "Photos",
              style: Theme.of(context).textTheme.body1,
            ),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.map),
            title: new Text("Detisnations",
                style: Theme.of(context).textTheme.body1),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.chat_bubble),
            title: new Text("Chats", style: Theme.of(context).textTheme.body1),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.people),
            title:
                new Text("Friends", style: Theme.of(context).textTheme.body1),
          ),
        ],
      ),
    );
  }
}

class TripPageHeader extends StatefulWidget {
  final DocumentSnapshot document;
  double headerHeight;
  FractionallySizedBox background;
  FractionallySizedBox info;
  TripPageHeader({@required this.document, @required this.headerHeight});

  @override
  TripPageHeaderState createState() {
    return new TripPageHeaderState();
  }
}

class TripPageHeaderState extends State<TripPageHeader> {
  @override
  Widget build(BuildContext context) {
    widget.background = new FractionallySizedBox(
      widthFactor: 1.0,
      child: AnimatedContainer(
        constraints: new BoxConstraints(
          minHeight: 64.0,
        ),
        duration: new Duration(milliseconds: 150),
        height: widget.headerHeight,
        child: new CachedNetworkImage(
          errorWidget: Center(child: Icon(Icons.image)),
          placeholder: new CircularProgressIndicator(),
          imageUrl: widget.document["mainImageUrl"],
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );

    widget.info = new FractionallySizedBox(
      widthFactor: 1.0,
      child: new DecoratedBox(
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          colors: [
            Theme.of(context).accentColor,
            Theme.of(context).accentColor,
            Theme.of(context).accentColor.withOpacity(0.7),
            Theme.of(context).accentColor.withOpacity(0.5),
          ],
        )),
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(
                widget.document["name"],
                style: Theme.of(context).textTheme.title,
              ),
              new Text(
                DateTime.parse(widget.document["startDate"].toString())
                        .day
                        .toString() +
                    "/" +
                    DateTime.parse(widget.document["startDate"].toString())
                        .month
                        .toString() +
                    "/" +
                    DateTime.parse(widget.document["startDate"].toString())
                        .year
                        .toString(),
                style: Theme.of(context).textTheme.body2,
              )
            ],
          ),
        ),
      ),
    );
    return new Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 5.0, color: Colors.black54)]),
      child: new Hero(
        tag: widget.document.documentID,
        child: new Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            widget.background,
            widget.info,
          ],
        ),
      ),
    );
  }
}

class TabPage extends StatelessWidget {
  Key key;
  double opacity;
  final Widget child;
  final Color color;
  TabPage({this.key, @required this.opacity, @required this.child, this.color});
  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      curve: Curves.ease,
      duration: new Duration(milliseconds: 300),
      opacity: opacity,
      child: new Container(
        color: this.color,
        child: new FractionallySizedBox(
          widthFactor: 1.0,
          child: this.child,
        ),
      ),
    );
  }
}

class TripImages extends StatelessWidget {
  ScrollController controller;
  AsyncSnapshot<QuerySnapshot> snapshot;

  TripImages({this.controller, this.snapshot});
  @override
  Widget build(BuildContext context) {
    return new ListView(
      controller: controller,
      children: snapshot.data.documents.map((image) {
        return new Card(
          color: Colors.transparent,
          child: new CachedNetworkImage(
            imageUrl: image["url"],
            placeholder: new Center(
              child: new CircularProgressIndicator(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
