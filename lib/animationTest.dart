import 'package:flutter/material.dart';

class CustomAnimatedContainer extends StatefulWidget {
  @override
  _CustomAnimatedContainerState createState() =>
      new _CustomAnimatedContainerState();
}

class _CustomAnimatedContainerState extends State<CustomAnimatedContainer>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  var height = 500.0;
  AnimationController animationController;
  @override
  void initState() {
    Tween<double> tween = new Tween<double>(
      begin: 0.0,
      end: 500.0,
    );
    animationController = new AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 2000,
        ));
    animation = tween.animate(animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("AnimatedContainer"),
      ),
      body: Column(
        children: <Widget>[
          GestureDetector(
            onVerticalDragUpdate: (detail) {
              setState(() {
                height += detail.delta.dy;
              });
            },
            child: Container(
              height: height,
              color: Colors.red,
            ),
          ),
          RaisedButton(
            child: Text("Animate"),
            onPressed: () {
              print("pressed");
              animationController.forward();
            },
          ),
          FriendCard(),
        ],
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
                blurRadius: 5.0,
                offset: Offset(5.0, 5.0),
                color: Colors.black26)
          ]),
      child: new ListTile(
        leading: CircleAvatar(backgroundImage: AssetImage("assets/logo.png")),
        title: Container(
          child: Text("Nguyễn Xuân Nhị"),
        ),
        trailing: Checkbox(
          value: false,
          onChanged: (value) {
            Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                  value.toString(),
                )));
          },
        ),
      ),
    );
  }
}
