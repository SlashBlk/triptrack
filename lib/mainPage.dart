import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:triptrack/animationTest.dart';
import 'package:triptrack/newTripPage.dart';
import 'package:triptrack/tripCardClipper.dart';
import 'package:triptrack/appBar.dart' as appBar;
import 'package:triptrack/tripList.dart';
import 'package:triptrack/tripPage.dart';
import 'package:triptrack/utility.dart';
//import 'package:cloud_functions/cloud_functions.dart';

class MainPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseStorage storage;
  FirebaseUser currentUser;
  Firestore db;
  Widget body;
  String userId;
  DocumentReference currentUserRef;
  var mainAxisSizes = [2, 3];
  var crossAxisSizes = [2, 4];
  ScrollController scrollController = new ScrollController();
  MainPage({
    @required this.currentUser,
    @required this.db,
    @required this.userId,
    @required this.storage,
  });

  @override
  State<StatefulWidget> createState() {
    return new _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int tabIdex = 0;

  @override
  Widget build(BuildContext context) {
    var hotPage = new TabPage(
      key: new Key("1"),
      opacity: 0.0,
      child: TripList(
        currentUser: widget.currentUser,
        db: widget.db,
        storage: widget.storage,
        userId: widget.userId,
      ),
    );
    var nearByPage = new TabPage(
      key: new Key("2"),
      opacity: 0.0,
      child: Text("Near by"),
    );
    var mePage = new TabPage(
      key: new Key("3"),
      opacity: 0.0,
      child: Text("Me"),
    );
    var pages = [hotPage, nearByPage, mePage];
    var page = pages[tabIdex];
    var pagesLength = pages.length - 1;
    pages.removeAt(tabIdex);
    pages.insert(pagesLength, page);
    pages[pagesLength].opacity = 1.0;
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIdex,
        onTap: (index) {
          tabIdex = index;
          setState(() {
            tabIdex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            title: Text("Hot"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            title: Text("Near by"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Me"),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (BuildContext context) {
            return new NewTripPage(
                currentUserRef: widget.currentUserRef,
                db: widget.db,
                storage: widget.storage);
          }));
        },
        child: new Icon(
          Icons.add,
        ),
      ),
      key: widget._scaffoldKey,
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: new ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.currentUser.photoUrl,
                  ),
                ),
                title: Text(widget.currentUser.displayName),
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (buidcontext) {
                    return CustomAnimatedContainer();
                  }));
                },
              ),
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        title: new Text("TripTrack"),
        centerTitle: true,
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new GestureDetector(
              onHorizontalDragEnd: (detail) {
                if (detail.primaryVelocity < 0) {
                  if (!(tabIdex == 2))
                    tabIdex++;
                  else
                    tabIdex = 0;
                  setState(() {});
                }
                if (detail.primaryVelocity > 0) {
                  if (!(tabIdex == 0))
                    tabIdex--;
                  else
                    tabIdex = 2;
                  setState(() {});
                }
              },
              child: new Stack(
                fit: StackFit.expand,
                children: pages,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
