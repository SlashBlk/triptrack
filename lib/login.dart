import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:triptrack/mainPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginPage extends StatefulWidget {
  Firestore db;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int dem;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  TextEditingController idController;
  TextEditingController passController;
  FirebaseStorage storage;
  LoginPage(Firestore db, FirebaseStorage storage) {
    this.db = db;
    this.storage = storage;
    idController = new TextEditingController();
    passController = new TextEditingController();
  }
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _message = "";
  FirebaseUser currentUser;
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  LoginPageState() {
    //upHinh();
  }
  void chuyenTrangMain(String documentID) {
    Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => new MainPage(
                  userId: documentID,
                  currentUser: currentUser,
                  db: widget.db,
                  storage: widget.storage,
                )));
  }

  Future<Null> signInWithFacebook() async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        widget._auth
            .signInWithFacebook(accessToken: accessToken.token)
            .then((user) {
          currentUser = user;
        }).catchError((error) {
          print(accessToken.toMap());
          _showMessage(
              "Email đã tồn tại! Vui lòng đăng nhập lại bằng hình thức đã dùng trước đó.");
        });
        if (currentUser != null) {
          var users = await widget.db
              .collection("users")
              .where("uid", isEqualTo: currentUser.uid)
              .getDocuments();
          if (users.documents.length == 0) {
            chuyenTrangMain(await createNewUser(accessToken.token, ""));
          } else {
            chuyenTrangMain(users.documents.first.documentID);
          }
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<Null> _facebookLogOut() async {
    await facebookSignIn.logOut();
    _showMessage('Logged out.');
  }

  signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await widget._googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    currentUser = await widget._auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    if (currentUser != null) {
      var users = await widget.db
          .collection("users")
          .where("uid", isEqualTo: currentUser.uid)
          .getDocuments();
      if (users.documents.length == 0) {
        chuyenTrangMain(await createNewUser("", googleAuth.accessToken));
      } else {
        chuyenTrangMain(users.documents.first.documentID);
      }
    }
  }

  Future<String> signOut() async {
    widget._googleSignIn.signOut();
    widget._auth.signOut();

    return 'Out';
  }

  void fireBaseUpload(String path, StorageReference hotaruFolder) {
    var index = path.lastIndexOf("/");
    String fileName = path.substring(index + 1, path.length);
    try {
      if (!fileName.contains('thumbdata')) {
        var file = new File(path);
        StorageReference fileRef = hotaruFolder.child(fileName);
        var uploadTask = fileRef.putFile(file);
        uploadTask.future.then((onValue) {
          if (onValue.downloadUrl != null) {
            widget.dem++;
            print(widget.dem);
          }
        });
      }
    } catch (ex) {
      print(fileName);
    }
  }

  Future<String> createNewUser(
      String facebookAccessToken, String googleAccessToken) async {
    await widget.db
            .collection("users")
            .document(currentUser.uid)
            .setData({
      "uid": currentUser.uid,
      "facebookToken": facebookAccessToken,
      "googleToken": googleAccessToken,
      "image":currentUser.photoUrl,
      "name":currentUser.displayName,
    });
    return currentUser.uid;
        
  }

  @override
  Widget build(BuildContext context) {
    ScrollController mainController = new ScrollController();
    TextEditingController emailController = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();

    return new Scaffold(
      appBar: new AppBar(
        elevation: 4.0,
        title: new Text("TripTrack"),
        centerTitle: true,
      ),
      body: new Container(
        alignment: AlignmentDirectional.center,
        child: new Stack(
          children: <Widget>[
            new ListView(
              controller: mainController,
              children: <Widget>[
                Text(_message == null ? "" : _message),
                new Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: new Image.asset("assets/logo.png"),
                ),
                new Container(
                  padding: new EdgeInsets.fromLTRB(35.0, 0.0, 73.0, 30.0),
                  child: new Column(
                    children: <Widget>[
                      new TextField(
                        controller: emailController,
                        onChanged: (text) {
                          mainController.animateTo(
                              mainController.position.maxScrollExtent,
                              curve: Curves.ease,
                              duration: new Duration(milliseconds: 200));
                        },
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.person),
                          hintText: "Email",
                        ),
                      ),
                      new TextField(
                        controller: passwordController,
                        decoration: new InputDecoration(
                            icon: new Icon(Icons.lock), hintText: "Mật khẩu"),
                      ),
                    ],
                  ),
                ),
                new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new MaterializeButton(
                        borderRadius: new BorderRadius.circular(5.0),
                        firstColor: new Color(0xffFF5252),
                        secondColor: new Color(0xfff48fb1),
                        height: 50.0,
                        width: 120.0,
                        text: "Google",
                        icon: new Image.asset(
                          "assets/icons/googleIcon.png",
                          width: 25.0,
                        ),
                        onPressed: () {
                          signInWithGoogle();
                        },
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new MaterializeButton(
                        borderRadius: new BorderRadius.circular(5.0),
                        firstColor: Color(0xff0288d1),
                        secondColor: Color(0xff26c6da),
                        icon: new Image.asset(
                          "assets/icons/facebookIcon.png",
                          width: 25.0,
                        ),
                        text: "Facebook",
                        height: 50.0,
                        width: 120.0,
                        onPressed: () {
                          signInWithFacebook();
                        },
                      ),
                    ),
                  ],
                ),
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Builder(
                      builder: (BuildContext _context) {
                        return new MaterializeButton(
                          borderRadius: new BorderRadius.circular(5.0),
                          text: "Đăng xuất",
                          firstColor: Colors.grey,
                          secondColor: Colors.grey,
                          height: 50.0,
                          width: 120.0,
                          icon: new Image.asset(
                            "assets/icons/googleIcon.png",
                            width: 5.0,
                          ),
                          onPressed: () async {
                            await signOut();
                            Scaffold.of(_context).showSnackBar(new SnackBar(
                                  content: new Text("Đã đăng xuất"),
                                ));
                          },
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MaterializeButton extends StatelessWidget {
  const MaterializeButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    @required this.icon,
    @required this.firstColor,
    @required this.secondColor,
    @required this.width,
    @required this.height,
    @required this.borderRadius,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Image icon;
  final Color firstColor;
  final Color secondColor;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      shape: new RoundedRectangleBorder(borderRadius: borderRadius),
      padding: new EdgeInsets.all(0.0),
      child: new Container(
        width: width,
        height: height,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: const Alignment(-1.0, 0.0),
            end: const Alignment(0.6, 0.0),
            colors: <Color>[firstColor, secondColor],
          ),
        ),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Text(this.text, style: new TextStyle(color: Colors.white)),
            new Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
              child: icon,
            )
          ],
        ),
      ),
      onPressed: () {
        onPressed();
      },
    );
  }
}
