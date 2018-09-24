import 'package:flutter/material.dart';

class Utility {
  static PageRouteBuilder customPageRouteBuilder(Widget child) {
    return new PageRouteBuilder(
      transitionDuration: new Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return child;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return new FadeTransition(
          opacity: new Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: child, // child is the value returned by pageBuilder
        );
      },
    );
  }
}
