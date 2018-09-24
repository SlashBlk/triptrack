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
import 'package:triptrack/tripPage.dart';
import 'package:triptrack/utility.dart';

class TripList extends StatefulWidget {
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
  TripList({
    @required this.currentUser,
    @required this.db,
    @required this.userId,
    @required this.storage,
  });

  @override
  _TripListState createState() => new _TripListState();
}

class _TripListState extends State<TripList> {
  Offset currentPointerPosition;
  List<StaggeredTile> _staggeredTiles = new List<StaggeredTile>();
  ramdomTileSize(String name) {
    var random = new Random();
    var crossAxisSize = 0;
    var mainAxisSize = 0;

    var totalMainAxizSize = 0;
    var totalCrossAxisSize = 0;
    var tong23Chan = 0;
    var tong23Le = 0;
    var dienTichTongHinh = 0.0;

    _staggeredTiles.forEach((f) {
      dienTichTongHinh += (f.crossAxisCellCount * f.mainAxisCellCount);

      if (f.crossAxisCellCount == 2 &&
          f.mainAxisCellCount == 3 &&
          _staggeredTiles.indexOf(f) % 2 == 0) tong23Chan++;
      if (f.crossAxisCellCount == 2 &&
          f.mainAxisCellCount == 3 &&
          _staggeredTiles.indexOf(f) % 2 != 0) tong23Le++;
      totalCrossAxisSize += f.crossAxisCellCount;
      if (f.crossAxisCellCount == 4)
        totalMainAxizSize += f.mainAxisCellCount * 2;
      else
        totalMainAxizSize += f.mainAxisCellCount;
    });
    if (dienTichTongHinh % 8 > 0) {
      widget.crossAxisSizes.remove(4);
    }
    if (totalCrossAxisSize % 4 > 0) {
      widget.crossAxisSizes.remove(4);
    }
    if (totalMainAxizSize % 2 > 0) {
      widget.crossAxisSizes.remove(4);
    }
    //else {
    //crossAxisSizes.remove(4);
    // if (totalMainAxizSize % 2 > 0) {
    //   crossAxisSizes.remove(4);
    // }
    // else {
    //   if (!crossAxisSizes.contains(4)) {
    //     crossAxisSizes.add(4);
    //   }
    // }
    //}
    if (tong23Chan != tong23Le) {
      widget.crossAxisSizes.remove(4);
    }
    mainAxisSize =
        widget.mainAxisSizes[random.nextInt(widget.mainAxisSizes.length)];
    crossAxisSize =
        widget.crossAxisSizes[random.nextInt(widget.crossAxisSizes.length)];
    if (!widget.crossAxisSizes.contains(4)) {
      widget.crossAxisSizes.add(4);
    }
    return new StaggeredTile.count(crossAxisSize, mainAxisSize);
  }
  @override
  Widget build(BuildContext context) {
    widget.currentUserRef =
        widget.db.collection("users").document(widget.userId);
    widget.body = Column(
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
              child: Stack(children: [
            ClipPath(
              clipper: TripCardClipper(),
              child: StreamBuilder(
                stream: widget.currentUserRef
                    .collection('trips')
                    .orderBy('startDate')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return new Text('Loading...');

                  var staggeredGridview = StaggeredGridView.count(
                    controller: widget.scrollController,
                    crossAxisCount: 4,
                    staggeredTiles: _staggeredTiles,
                    children: snapshot.data.documents.map((tripDocument) {
                      if (_staggeredTiles.length <
                          snapshot.data.documents.length)
                        _staggeredTiles
                            .add(ramdomTileSize(tripDocument["name"]));
                      return GestureDetector(
                        onTapDown: (detail) {
                          currentPointerPosition = detail.globalPosition;
                        },
                        onLongPress: () async {
                          showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                  currentPointerPosition.dx,
                                  currentPointerPosition.dy - 100,
                                  currentPointerPosition.dx + 100,
                                  currentPointerPosition.dy + 100),
                              items: [
                                PopupMenuItem(
                                    value: tripDocument.reference.path,
                                    child: new Text(
                                      "Xóa",
                                      style: Theme.of(context).textTheme.body1,
                                    ))
                              ]).then((value) {
                            widget.db.document(value).delete().then((result) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("Đã xóa!"),
                                    duration: Duration(seconds: 2),
                                  ));
                            });
                          });
                        },
                        onTap: () {
                          Navigator.push(
                              context,
                              Utility.customPageRouteBuilder(new TripPage(widget.db, tripDocument,
                                      widget.currentUser, widget.storage)));
                        },
                        child: new Card(
                          child: new Hero(
                            tag: tripDocument.documentID,
                            child: new Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                                new FractionallySizedBox(
                                  heightFactor: 1.0,
                                  widthFactor: 1.0,
                                  child: new CachedNetworkImage(
                                    alignment: Alignment.center,
                                    placeholder: new Center(
                                      child: new CircularProgressIndicator(
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    imageUrl: tripDocument["mainImageUrl"],
                                    errorWidget:
                                        Center(child: Icon(Icons.image)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                new FractionallySizedBox(
                                  widthFactor: 1.0,
                                  child: new DecoratedBox(
                                    decoration: new BoxDecoration(
                                        gradient: new LinearGradient(
                                      colors: [
                                        Theme.of(context).accentColor,
                                        Theme.of(context).accentColor,
                                        Theme
                                            .of(context)
                                            .primaryColor
                                            .withOpacity(0.7),
                                        Theme
                                            .of(context)
                                            .primaryColor
                                            .withOpacity(0.5),
                                      ],
                                    )),
                                    child: new Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            tripDocument["name"],
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .title,
                                          ),
                                          new Text(
                                            DateTime
                                                    .parse(tripDocument[
                                                            "startDate"]
                                                        .toString())
                                                    .day
                                                    .toString() +
                                                "/" +
                                                DateTime
                                                    .parse(tripDocument[
                                                            "startDate"]
                                                        .toString())
                                                    .month
                                                    .toString() +
                                                "/" +
                                                DateTime
                                                    .parse(tripDocument[
                                                            "startDate"]
                                                        .toString())
                                                    .year
                                                    .toString(),
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .body2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    padding: const EdgeInsets.all(4.0),
                  );
                  return staggeredGridview;
                },
              ),
            ),
          ])),
        ]);
    return widget.body;
  }
}
