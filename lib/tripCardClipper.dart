import 'package:flutter/widgets.dart';

class TripCardClipper extends CustomClipper<Path>
{
  @override
  Path getClip(Size size) {
    double i=0.0;
    Path path = new Path();
    path.moveTo(i, size.height-i);
    path.lineTo(size.width-i, size.height-i);
    path.lineTo(size.width-i, i);
    path.lineTo(65.0, i);
    path.lineTo(i, 65.0);
    path.lineTo(i, size.height-i);
    return path;
    // TODO: implement getClip
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
    // TODO: implement shouldReclip
  }

}