import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/status/status_icon.dart';
import 'package:flutterhole_again/widget/status/toggle_button.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const StatusAppBar({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: <Widget>[
          Text(title),
          StatusIcon(),
        ],
      ),
      actions: <Widget>[
        ToggleButton(),
      ],
    );
  }
}