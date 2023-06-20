import 'dart:math';
import 'dart:ui';

import 'package:qr/qr.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/frame_builders/default_frame.dart';
import 'package:xml/xml.dart';

const Color black = Color(0xFF000000);

extension SvgString on Color {
  String toSvgString() {
    return '#${value.toRadixString(16).substring(2, 8)}${value.toRadixString(16).substring(0, 2)}';
  }
}

String generateQrCodeSvg(QrImage qrcode, List<SvgBuilder> builders,
    {FrameBuilder frameBuilder = const DefaultFrameBuilder()}) {
  XmlBuilder builder = XmlBuilder();
  builder.processing('xml', 'version="1.0"');

  frameBuilder.build(builder, qrcode, (builder, image) {
    for (var svgBuilder in builders) {
      svgBuilder.build(builder, image);
    }
  });

  return builder.buildDocument().toString();
}

String makeArc(
    double x, double y, double radius, double startAngle, double endAngle,
    {bool flip = false}) {
  double radians(double degrees) {
    return degrees * pi / 180.0;
  }

  if (radius < 0) {
    return 'L ${x + radius * cos(radians(startAngle)) + radius * cos(radians(endAngle))} ${y + radius * sin(radians(startAngle)) + radius * sin(radians(endAngle))}';
  } else if (radius == 0) {
    return 'L $x $y';
  }

  var d = [
    "L",
    x + radius * cos(radians(startAngle)),
    y + radius * sin(radians(startAngle)),
    "A",
    radius,
    radius,
    0,
    (endAngle - startAngle).abs() <= 180 ? 0 : 1,
    endAngle < startAngle != flip ? 0 : 1,
    x + radius * cos(radians(endAngle)),
    y + radius * sin(radians(endAngle)),
  ].join(" ");

  return d;
}

abstract class FrameBuilder {
  const FrameBuilder();
  void build(XmlBuilder builder, QrImage image,
      void Function(XmlBuilder builder, QrImage image) buildQrCode);
}

abstract class SvgBuilder {
  const SvgBuilder({this.color = black});
  final Color color;
  void build(XmlBuilder builder, QrImage image);
}

abstract class CornerBuilder extends SvgBuilder {
  const CornerBuilder({this.orientInwards = true, super.color});
  final bool orientInwards;
}

abstract class ContentBuilder extends SvgBuilder {
  const ContentBuilder(
      {this.skipCorners = false, this.iconCutout = 0, super.color});
  final bool skipCorners;
  final int iconCutout;

  bool shouldDisplay(int x, int y, QrImage image) {
    if (x < 0 || y < 0 || x >= image.moduleCount || y >= image.moduleCount) {
      return false;
    }

    var border = (image.moduleCount - iconCutout) / 2;
    if (x >= border &&
        x < image.moduleCount - border &&
        y >= border &&
        y < image.moduleCount - border) {
      return false;
    }

    return !(skipCorners &&
            ((x < 7 && y < 7) ||
                (x < 7 && y >= image.moduleCount - 7) ||
                (x >= image.moduleCount - 7 && y < 7))) &&
        image.isDark(y, x);
  }
}
