import 'package:flutter/material.dart';

class AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
      child: new Stack(children: <Widget>[
                new Positioned(
                  top: 30.0,
                  left: 5.0,
                  child: new IconButton(
                    icon: new Icon(
                      Icons.menu,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Text(
                        "TripTrack",
                        style: Theme.of(context).textTheme.title.copyWith(color: Colors.black54)
                      )
                    ],
                  ),
                ),
              ])
    );
  }
}
