import 'package:flutter/widgets.dart';

class ShadowClipper extends CustomClipper<Path>
{
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(60.0, 0.0);
    path.lineTo(0.0, 60.0);
    path.lineTo(0.0, size.height);
    return path;
    // TODO: implement getClip
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
    // TODO: implement shouldReclip
  }

}