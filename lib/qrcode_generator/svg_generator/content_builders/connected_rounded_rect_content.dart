import 'dart:ui';

import 'package:qr/qr.dart';
import 'package:xml/xml.dart';

import '../svg_generator.dart';

class ConnectedRoundedRectContentBuilder extends ContentBuilder {
  const ConnectedRoundedRectContentBuilder(
      {required this.radius, super.skipCorners, super.iconCutout, super.color});
  final double radius;

  @override
  void build(XmlBuilder builder, QrImage image) {
    List<List<List<_PathPatch>>> patches =
        List<List<List<_PathPatch>>>.generate(
            image.moduleCount,
            (index) => List<List<_PathPatch>>.generate(
                image.moduleCount, (idx) => []));

    _PathPatch getFullPatch(_PathPatch p) {
      _PathPatch t = p;
      while (t.includedIn != null) {
        t = t.includedIn!;
      }
      return t;
    }

    for (var y = 0; y < image.moduleCount; y++) {
      for (var x = 0; x < image.moduleCount; x++) {
        if (shouldDisplay(x, y - 1, image) &&
            shouldDisplay(x - 1, y, image) &&
            (shouldDisplay(x, y, image) ||
                shouldDisplay(x - 1, y - 1, image))) {
          for (var lPatch in patches[x - 1][y]) {
            for (var uPatch in patches[x][y - 1]) {
              if (getFullPatch(lPatch) != getFullPatch(uPatch)) {
                getFullPatch(uPatch).mergeIn(getFullPatch(lPatch));
              }
            }
          }
        }

        if (!shouldDisplay(x, y, image)) {
          continue;
        }
        List<_PathPatch> newPatches = _getPatch(
          shouldDisplay(x, y - 1, image),
          shouldDisplay(x + 1, y, image),
          shouldDisplay(x, y + 1, image),
          shouldDisplay(x - 1, y, image),
          x.toDouble(),
          y.toDouble(),
        );
        if (shouldDisplay(x - 1, y - 1, image)) {
          for (var nPatch in newPatches) {
            for (var patch in patches[x - 1][y - 1]) {
              if (getFullPatch(nPatch) != getFullPatch(patch)) {
                getFullPatch(patch).mergeIn(getFullPatch(nPatch));
              }
            }
          }
        }
        if (shouldDisplay(x, y - 1, image)) {
          for (var nPatch in newPatches) {
            for (var uPatch in patches[x][y - 1]) {
              if (getFullPatch(nPatch) != getFullPatch(uPatch)) {
                getFullPatch(uPatch).mergeIn(getFullPatch(nPatch));
              }
            }
          }
        }
        if (shouldDisplay(x - 1, y, image)) {
          for (var nPatch in newPatches) {
            for (var lPatch in patches[x - 1][y]) {
              if (getFullPatch(nPatch) != getFullPatch(lPatch)) {
                getFullPatch(lPatch).mergeIn(getFullPatch(nPatch));
              }
            }
          }
        }

        patches[x][y].addAll(newPatches);
      }
    }

    Set<_PathPatch> uniquePaths = {};
    for (var y = 0; y < image.moduleCount; y++) {
      for (var x = 0; x < image.moduleCount; x++) {
        for (var patch in patches[x][y]) {
          uniquePaths.add(getFullPatch(patch));
        }
      }
    }

    builder.element(
      "path",
      attributes: {
        'fill': color.toSvgString(),
        'd': uniquePaths.fold(
          "",
          (String s, _PathPatch p) =>
              "${s}M${p.first.dx} ${p.first.dy} ${p.inBetween} L${p.last.dx} ${p.last.dy} Z ",
        ),
      },
    );
  }

  List<_PathPatch> _getPatch(
      bool up, bool right, bool down, bool left, double x, double y) {
    // no side
    if (!up && !right && !down && !left) {
      var p = _PathPatch();
      p.first = Offset(x, y + radius);
      p.inBetween =
          '${makeArc(x + radius, y + radius, radius, 180, 270)} ${makeArc(x + 1 - radius, y + radius, radius, 270, 360)} ${makeArc(x + 1 - radius, y + 1 - radius, radius, 0, 90)} ${makeArc(x + radius, y + 1 - radius, radius, 90, 180)}';
      p.last = Offset(x, y + 1 - radius);
      return [p];
    }
    // one side
    if (up && !right && !down && !left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y);
      p.inBetween =
          '${makeArc(x + 1 - radius, y + 1 - radius, radius, 0, 90)} ${makeArc(x + radius, y + 1 - radius, radius, 90, 180)}';
      p.last = Offset(x, y);
      return [p];
    }
    if (!up && right && !down && !left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y + 1);
      p.inBetween =
          '${makeArc(x + radius, y + 1 - radius, radius, 90, 180)} ${makeArc(x + radius, y + radius, radius, 180, 270)}';
      p.last = Offset(x + 1, y);
      return [p];
    }
    if (!up && !right && down && !left) {
      var p = _PathPatch();
      p.first = Offset(x, y + 1);
      p.inBetween =
          '${makeArc(x + radius, y + radius, radius, 180, 270)} ${makeArc(x + 1 - radius, y + radius, radius, 270, 360)}';
      p.last = Offset(x + 1, y + 1);
      return [p];
    }
    if (!up && !right && !down && left) {
      var p = _PathPatch();
      p.first = Offset(x, y);
      p.inBetween =
          '${makeArc(x + 1 - radius, y + radius, radius, 270, 360)} ${makeArc(x + 1 - radius, y + 1 - radius, radius, 0, 90)}';
      p.last = Offset(x, y + 1);
      return [p];
    }
    // two adjanced sides
    if (up && right && !down && !left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y + 1);
      p.inBetween = makeArc(x + radius, y + 1 - radius, radius, 90, 180);
      p.last = Offset(x, y);
      return [p];
    }
    if (!up && right && down && !left) {
      var p = _PathPatch();
      p.first = Offset(x, y + 1);
      p.inBetween = makeArc(x + radius, y + radius, radius, 180, 270);
      p.last = Offset(x + 1, y);
      return [p];
    }
    if (!up && !right && down && left) {
      var p = _PathPatch();
      p.first = Offset(x, y);
      p.inBetween = makeArc(x + 1 - radius, y + radius, radius, 270, 360);
      p.last = Offset(x + 1, y + 1);
      return [p];
    }
    if (up && !right && !down && left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y);
      p.inBetween = makeArc(x + 1 - radius, y + 1 - radius, radius, 0, 90);
      p.last = Offset(x, y + 1);
      return [p];
    }
    // two distached sides
    if (up && !right && down && !left) {
      var p1 = _PathPatch();
      p1.first = Offset(x, y + 1);
      p1.last = Offset(x, y);
      var p2 = _PathPatch();
      p2.first = Offset(x + 1, y);
      p2.last = Offset(x + 1, y + 1);
      return [p1, p2];
    }
    if (!up && right && !down && left) {
      var p1 = _PathPatch();
      p1.first = Offset(x, y);
      p1.last = Offset(x + 1, y);
      var p2 = _PathPatch();
      p2.first = Offset(x + 1, y + 1);
      p2.last = Offset(x, y + 1);
      return [p1, p2];
    }
    // three sides
    if (up && right && down && !left) {
      var p = _PathPatch();
      p.first = Offset(x, y + 1);
      p.last = Offset(x, y);
      return [p];
    }
    if (!up && right && down && left) {
      var p = _PathPatch();
      p.first = Offset(x, y);
      p.last = Offset(x + 1, y);
      return [p];
    }
    if (up && !right && down && left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y);
      p.last = Offset(x + 1, y + 1);
      return [p];
    }
    if (up && right && !down && left) {
      var p = _PathPatch();
      p.first = Offset(x + 1, y + 1);
      p.last = Offset(x, y + 1);
      return [p];
    }
    // four sides
    if (up && right && down && left) {
      return [];
    }
    return [];
  }
}

class _PathPatch {
  late Offset first;
  late Offset last;
  String inBetween = "";
  //List<Offset | String> points = [];
  _PathPatch? includedIn;

  void mergeIn(_PathPatch p) {
    if (last == p.first) {
      // merge after
      inBetween = '$inBetween L${last.dx} ${last.dy} ${p.inBetween}';
      last = p.last;
      p.first = first;
      p.includedIn = this;
    } else if (first == p.last) {
      // merge before
      inBetween = '${p.inBetween} L${first.dx} ${first.dy} $inBetween';
      first = p.first;
      p.last = last;
      p.includedIn = this;
    }
  }

  _PathPatch();
}
