import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'page_route_builder.dart';

extension StateRoute on State {
  // void pushNamed(routeName) {
  //   final Widget child = routes[routeName](context);
  //   Navigator.of(context).push(CustomRoute(child));
  // }

  void push(Widget child) {
    Navigator.of(context).push(CustomRoute(child));
  }

  Future<void> pop() async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

extension ContextRoute on BuildContext {
  // void pushNamed(routeName) {
  //   final Widget child = routes[routeName](this);
  //   Navigator.of(this).push(CustomRoute(child));
  // }

  void push(Widget child) {
    Navigator.of(this).push(MaterialPageRoute(builder: (_) {
      return child;
    }));
  }

  // void pushNamedReplacement(routeName) {
  //   final Widget child = routes[routeName](this);
  //   Navigator.of(this).pushReplacement(CustomRoute(child));
  // }

  Future<void> pop() async {
    Navigator.of(this).pop();
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
