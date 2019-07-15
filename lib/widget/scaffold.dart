import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/default_end_drawer.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const DefaultScaffold({
    Key key,
    @required this.title,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: StatusAppBar(title: title),
      drawer: DefaultDrawer(),
      endDrawer: DefaultEndDrawer(),
      body: body,
    );
  }
}

class SimpleScaffold extends StatelessWidget {
  final String titleString;
  final Widget body;
  final Widget drawer;

  const SimpleScaffold({
    Key key,
    @required this.titleString,
    @required this.body,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(this.titleString);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: Text(
            titleString,
            overflow: TextOverflow.fade,
          )),
      drawer: this.drawer,
      body: body,
    );
  }
}