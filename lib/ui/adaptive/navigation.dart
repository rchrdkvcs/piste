import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

Future<T?> ouvrirPage<T>(BuildContext context, WidgetBuilder builder) {
  final route = estCupertino(context)
      ? CupertinoPageRoute<T>(builder: builder)
      : MaterialPageRoute<T>(builder: builder);
  return Navigator.of(context).push(route);
}

Future<T?> ouvrirModale<T>(BuildContext context, WidgetBuilder builder) {
  if (estCupertino(context)) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoSheetRoute<T>(
        scrollableBuilder: (context, _) => builder(context),
      ),
    );
  }
  return Navigator.of(context)
      .push(MaterialPageRoute<T>(builder: builder, fullscreenDialog: true));
}
