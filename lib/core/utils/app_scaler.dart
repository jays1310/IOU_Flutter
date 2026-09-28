import 'package:flutter/widgets.dart';

class AppScaler {
  final BuildContext context;

  AppScaler(this.context);

  static const double designWidth = 411;
  static const double designHeight = 891;

  Size get _size => MediaQuery.of(context).size;

  double w(double value) => value * _size.width / designWidth;

  double h(double value) => value * _size.height / designHeight;

  double sp(double value) {
    final scale = (_size.width / designWidth + _size.height / designHeight) / 2;
    return value * scale;
  }
}