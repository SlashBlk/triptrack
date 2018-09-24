import 'package:flutter/material.dart';

class Destination extends StatefulWidget {
  Icon icon;
  bool checked;
  String name;
  String description;
  var onchangedHandle;
  Destination(
      {@required this.icon,
      @required this.checked,
      @required this.name,
      @required this.description,
      this.onchangedHandle});

  @override
  _DestinationState createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DecoratedBox(
        position: DecorationPosition.background,
        decoration: new BoxDecoration(boxShadow: [
          BoxShadow(
            color: const Color(0x80bbbdbf),
            offset: Offset(10.0, 10.0),
            blurRadius: 20.0,
          ),
        ]),
        child: Container(
          color: Colors.white,
          child: new ListTile(
            leading: widget.icon,
            title: new Text(widget.name,style: new TextStyle(color:Colors.black),),
            subtitle: new Text(widget.description),
            trailing: new Checkbox(
              value: widget.checked,
              onChanged: (value) {
               widget.onchangedHandle();
              },
            ),
          ),
        ),
      ),
    );
  }
}
