import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewTripPage extends StatefulWidget {
  FirebaseStorage storage;
  Firestore db;
  FirebaseUser currentUser;
  NewTripPage(
      {@required this.storage,
      @required this.db,
      @required this.currentUser});

  @override
  NewTripPageState createState() {
    return new NewTripPageState();
  }
}

class NewTripPageState extends State<NewTripPage> {
  TextEditingController tripNameController = new TextEditingController();
  TextEditingController startDateController = new TextEditingController();
  FocusNode formFocusNode;
  ImageUploader imageUploader;
  @override
  Widget build(BuildContext context) {
    imageUploader = imageUploader == null
        ? new ImageUploader(
            currentUser: widget.currentUser,
            storage: widget.storage,
          )
        : imageUploader;
    formFocusNode = new FocusNode();
    formFocusNode.addListener(() async {
      if (formFocusNode.hasFocus) {
        var date = await showDatePicker(
          context: context,
          firstDate: new DateTime(1970),
          lastDate: new DateTime(2099),
          initialDate: new DateTime.now(),
        );
        if (date != null) startDateController.text = date.toLocal().toString();
        formFocusNode.unfocus();
      }
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TripTrack"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              child: SingleChildScrollView(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 14.0),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Going on another adventure?",
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ),
                    new TextField(
                        style: new TextStyle(color: Colors.black),
                        controller: tripNameController,
                        decoration: new InputDecoration(
                          icon: Icon(Icons.landscape),
                          labelText: "Where to?",
                          hintText: "One does not simply walk into...",
                        )),
                    new TextField(
                      keyboardType: TextInputType.datetime,
                      style: new TextStyle(color: Colors.black),
                      focusNode: formFocusNode,
                      controller: startDateController,
                      decoration: new InputDecoration(
                        labelText: "When?",
                        hintText: "Once upon the time...",
                        icon: Icon(Icons.date_range),
                        // suffixIcon: IconButton(
                        //   icon: Icon(Icons.date_range),
                        //   onPressed: () async {
                        //     var date = await showDatePicker(
                        //       context: context,
                        //       firstDate: new DateTime(1970),
                        //       lastDate: new DateTime(2099),
                        //       initialDate: new DateTime.now(),
                        //     );
                        //     startDateController.text = date.toString();
                        //   },
                        // ),
                      ),
                    ),
                    Divider(),
                    imageUploader,
                    Divider(),
                    Container(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        color: Theme.of(context).buttonColor,
                        height: 40.0,
                        padding: new EdgeInsets.all(10.0),
                        child: Text(
                          "Proceed, fella!",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subhead
                              .copyWith(fontSize: 24.0),
                        ),
                        onPressed: () async {
                          await addNewTrip();
                          Navigator.pop(context);
                          //print(result);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  addNewTrip() async {
    // var batch = widget.db.batch();
    // var userRef = widget.currentUserRef;
    // var tripsRef =widget.db.collection("trips");
    // widget.db.runTransaction((transaction) {
    //   var tripsRef = widget.db.collection("/trips");
    //   transaction.set(tripsRef.document(), {
    //     "name": tripNameController.text,
    //     "startDate": startDateController.text,
    //     "mainImageUrl": imageUploader.imageUrl,
    //   });
    // });
    var trip ={
      "name": tripNameController.text,
      "startDate": startDateController.text,
      "mainImageUrl": imageUploader.imageUrl,
    };
    var newTrip = await widget.db.collection("/trips").add(trip);
    widget.db.collection("users/"+widget.currentUser.uid + "/trips").document(newTrip.documentID).setData(trip);

    //lookup
    widget.db.collection("/tripUser").document(newTrip.documentID).setData({
      widget.currentUser.uid: true,
    });
  }
}

class ImageUploader extends StatefulWidget {
  String imageUrl = "";
  FirebaseStorage storage;
  FirebaseUser currentUser;
  ImageUploader({this.currentUser, this.storage});
  @override
  _ImageUploaderState createState() => new _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  Future<String> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
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
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black12),
      ),
      height: 250.0,
      child: widget.imageUrl == ""
          ? Container(
              child: Center(
                child: IconButton(
                  iconSize: 48.0,
                  highlightColor: Colors.white,
                  splashColor: Color(0xffED5402),
                  icon: Icon(
                    Icons.photo_camera,
                  ),
                  onPressed: () async {
                    widget.imageUrl = await getImage();
                    setState(() {});
                  },
                ),
              ),
            )
          : CachedNetworkImage(
              placeholder: Center(
                child: CircularProgressIndicator(),
              ),
              imageUrl: widget.imageUrl,
            ),
    );
  }
}
