import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const importThemes = null;

extension ColorX on Color {
  Color computeForegroundColor([
    Color dark = Colors.black,
    Color light = Colors.white,
  ]) =>
      computeLuminance() > .5 ? dark : light;
}

class PiTheme extends StatelessWidget {
  const PiTheme({
    Key? key,
    required this.pi,
    required this.child,
  }) : super(key: key);

  final Pi pi;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context);
    return Theme(
      data: ThemeData.from(
          colorScheme: c.colorScheme.copyWith(
        primary: pi.primaryColor,
        onPrimary: Colors.green,
      )).copyWith(
        primaryColor: pi.primaryColor,
        accentColor: pi.accentColor,
        primaryColorDark: Colors.pink,
        textSelectionTheme: c.textSelectionTheme.copyWith(
          cursorColor: pi.accentColor,
          selectionColor: pi.accentColor.withOpacity(.5),
          selectionHandleColor: pi.accentColor,
        ),
        toggleableActiveColor: pi.primaryColor,
        buttonColor: pi.primaryColor.computeForegroundColor(),
        appBarTheme: c.appBarTheme.copyWith(
          backgroundColor: pi.primaryColor,
          titleTextStyle: TextStyle(
            color: Colors.green,
          ),
        ),
      ),
      child: child,
    );
  }
}

class ActivePiTheme extends HookWidget {
  const ActivePiTheme({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activePiProvider);
    return PiTheme(pi: active, child: child);
  }
}
