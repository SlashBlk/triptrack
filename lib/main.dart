import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:triptrack/login.dart';

Future<void> main() async {
  // final FirebaseApp app = await FirebaseApp.configure(
  //   name: 'test',
  //   options: const FirebaseOptions(
  //     googleAppID: '1:116302139649:android:ac0e8cb937e3a26f',
  //     apiKey: 'AIzaSyD4BUzFoovcYTTiBlcCBar_Dn2FnIP3Kes',
  //     projectID: 'roadtrip-8e75f',
  //   ),
  // );
  final FirebaseApp app = FirebaseApp.instance;
  final FirebaseStorage storage = new FirebaseStorage(
      app: app, storageBucket: 'gs://roadtrip-8e75f.appspot.com');
  final Firestore db = new Firestore(app: app);
  runApp(new App(app: app, storage: storage, db: db));
}

class App extends StatelessWidget {
  final FirebaseApp app;
  final FirebaseStorage storage;
  final Firestore db;
  bool chan = false;
  App({this.app, this.storage, this.db});
  @override
  Widget build(BuildContext context) {
    ThemeData green = new ThemeData(
      fontFamily: "BaiSau",
      primaryColor: Color(0xff9BD770),
      accentColor: Color(0xff66B032),
      backgroundColor: Color(0xff9BD770),
      canvasColor: Colors.white,
      inputDecorationTheme: new InputDecorationTheme(),
      accentIconTheme: new IconThemeData(
        color: Colors.white,
      ),
      primaryIconTheme: new IconThemeData(
        color: Color(0xff1B3409),
      ),
      iconTheme: new IconThemeData(
        color: Color(0xff1B3409),
      ),
      buttonColor: Color(0xff66B032),
      primaryTextTheme: TextTheme(
        title: TextStyle(color: Color(0xff1B3409), fontSize: 24.0),
        display1: TextStyle(fontSize: 28.0),
        body1: TextStyle(
          color: Color(0xff1B3409),
        ),
      ),
      textTheme: TextTheme(
        headline: TextStyle(
          color: Colors.white,
        ),
        title: TextStyle(color: Colors.white),
        subhead: TextStyle(color: Colors.black),
        body2: TextStyle(color: Colors.white),
      ),
    );
    ThemeData orangeWhite = new ThemeData(
      fontFamily: "BaiSau",
      primaryColor: new Color(0xffFB8604),
      accentColor: new Color(0xff975102),
      canvasColor: Color(0xffFEEEDC),
      backgroundColor: Color(0xffFFEBDC),
      dialogBackgroundColor: Color(0xffFFEBDC),
      primaryTextTheme: TextTheme(
        title: TextStyle(color: Color(0xff1B3409), fontSize: 24.0),
        display1: TextStyle(fontSize: 28.0),
        body1: TextStyle(
          color: Color(0xff1B3409),
        ),
      ),
      textTheme: TextTheme(
        headline: TextStyle(
          color: Colors.white,
        ),
        title: TextStyle(color: Colors.white),
        subhead: TextStyle(color: Colors.white),
      ),
    );
    ThemeData blackWhite = new ThemeData(
        bottomAppBarColor: Colors.black54,
        accentIconTheme: new IconThemeData(
          color: Colors.black54,
        ),
        primaryIconTheme: new IconThemeData(
          color: Colors.black54,
        ),
        iconTheme: new IconThemeData(
          color: Colors.black54,
        ),
        accentColor: Colors.black54,
        primaryColor: Colors.white,
        primaryColorLight: Colors.blue[10],
        canvasColor: Colors.white,
        backgroundColor: Colors.white,
        fontFamily: "BaiSau",
        inputDecorationTheme: new InputDecorationTheme(),
        primaryTextTheme: new TextTheme(
            display1: new TextStyle(
                color: Colors.black54,
                fontSize: 20.0 //DatePicker dialog's date's font size;
                ),
            title: TextStyle(
              color: Colors.black54,
            )),
        textTheme: new TextTheme(
          body1: TextStyle(color: Colors.black54),
          headline: new TextStyle(color: Colors.black54, fontSize: 12.0),
          display1: new TextStyle(color: Colors.black54, fontSize: 20.0),
          title: new TextStyle(
            color: Colors.black54,
          ),
          subhead: new TextStyle(color: Colors.black54),
          button: new TextStyle(
            color: Colors.black54,
          ),
          body2: new TextStyle(
            color: Colors.black54,
          ),
          caption: new TextStyle(
            color: Colors.black54,
          ),
        ));
    return new MaterialApp(
        title: 'Flutter Demo', theme: green, home: new LoginPage(db, storage));
  }
}
