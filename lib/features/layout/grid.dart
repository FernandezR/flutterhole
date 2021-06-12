import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';

class GridSpacer extends StatelessWidget {
  const GridSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: kGridSpacing);
  }
}

class TileTitle extends StatelessWidget {
  const TileTitle(
    this.title, {
    this.color,
    Key? key,
  }) : super(key: key);

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        color: color,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class GridIcon extends StatelessWidget {
  const GridIcon(
    this.primaryIcon, {
    Key? key,
    this.subIcon,
    this.subIconColor,
    this.isDark = false,
    this.size = 32.0,
  }) : super(key: key);

  final IconData primaryIcon;
  final IconData? subIcon;
  final Color? subIconColor;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Icon(
      primaryIcon,
      size: size,
      // color: Theme.of(context).brightness == Brightness.dark
      //     ? Colors.white.withOpacity(0.5)
      //     : Colors.black.withOpacity(0.5),
      color: Colors.white.withOpacity(0.5),
    );

    if (subIcon != null) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          primary,
          Positioned(
              left: 18.0,
              top: 18.0,
              child: Container(
                // color: Colors.purple,
                child: Icon(
                  subIcon,
                  size: 24.0,
                  color: subIconColor,
                ),
              )),
        ],
      );
    }
    return primary;
  }
}

class GridSectionHeader extends StatelessWidget {
  const GridSectionHeader(
    this.title,
    this.iconData, {
    Key? key,
  }) : super(key: key);

  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kGridSpacing),
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridIcon(iconData),
            ),
            TileTitle(title),
          ],
        ),
      ),
    );
  }
}

class GridClip extends StatelessWidget {
  const GridClip({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kGridSpacing))),
      child: child,
    );
  }
}

class GridCard extends StatelessWidget {
  const GridCard({
    Key? key,
    required this.child,
    this.color,
  }) : super(key: key);

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: GridClip(
        child: child,
      ),
    );
  }
}

class DoubleGridCard extends StatelessWidget {
  const DoubleGridCard({
    Key? key,
    required this.left,
    required this.right,
  }) : super(key: key);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GridCard(
            child: left,
          ),
        ),
        GridSpacer(),
        Expanded(
          child: Card(
            child: right,
          ),
        ),
      ],
    );
  }
}

class CenteredGridTileLoadingIndicator extends StatelessWidget {
  const CenteredGridTileLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class CenteredGridTileErrorIndicator extends StatelessWidget {
  const CenteredGridTileErrorIndicator(
    this.error, {
    Key? key,
    this.stacktrace,
  }) : super(key: key);

  final Object error;
  final StackTrace? stacktrace;

  @override
  Widget build(BuildContext context) {
    return Center(child: CodeCard(error.toString()));
  }
}