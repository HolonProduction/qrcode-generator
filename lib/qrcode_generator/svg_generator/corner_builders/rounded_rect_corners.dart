import 'package:qr/qr.dart';
import 'package:xml/xml.dart';

import '../svg_generator.dart';

abstract class RoundedRectCornerBuilder extends CornerBuilder {
  const RoundedRectCornerBuilder(this.topLeftRadius, this.topRightRadius,
      this.bottomLeftRadius, this.bottomRightRadius,
      {super.orientInwards, super.color});

  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;
}

class RoundedRectOuterCornerBuilder extends RoundedRectCornerBuilder {
  const RoundedRectOuterCornerBuilder(super.topLeftRadius, super.topRightRadius,
      super.bottomLeftRadius, super.bottomRightRadius,
      {super.orientInwards, super.color});

  @override
  void build(XmlBuilder builder, QrImage image) {
    buildCorner(builder, 0, 0, topLeftRadius, topRightRadius, bottomLeftRadius,
        bottomRightRadius);
    if (orientInwards) {
      buildCorner(builder, image.moduleCount - 7, 0, bottomLeftRadius,
          topLeftRadius, bottomRightRadius, topRightRadius);
      buildCorner(builder, 0, image.moduleCount - 7, topRightRadius,
          bottomRightRadius, topLeftRadius, bottomLeftRadius);
    } else {
      buildCorner(builder, image.moduleCount - 7, 0, topLeftRadius,
          topRightRadius, bottomLeftRadius, bottomRightRadius);
      buildCorner(builder, 0, image.moduleCount - 7, topLeftRadius,
          topRightRadius, bottomLeftRadius, bottomRightRadius);
    }
  }

  void buildCorner(XmlBuilder builder, double x, double y, double tlr,
      double trr, double blr, double brr) {
    builder.element('path', nest: () {
      builder.attribute('fill', color.toSvgString());
      builder.attribute('d',
          'M$x ${y + 3.5} ${makeArc(x + tlr, y + tlr, tlr, 180, 270)} ${makeArc(x + 7 - trr, y + trr, trr, 270, 360)} ${makeArc(x + 7 - brr, y + 7 - brr, brr, 0, 90)} ${makeArc(x + blr, y + 7 - blr, blr, 90, 180)} Z M${x + 1} ${y + 3.5} ${makeArc(x + blr, y + 7 - blr, blr - 1, 180, 90)} ${makeArc(x + 7 - brr, y + 7 - brr, brr - 1, 90, 0)} ${makeArc(x + 7 - trr, y + trr, trr - 1, 360, 270)} ${makeArc(x + tlr, y + tlr, tlr - 1, 270, 180)} Z');
    });
  }
}

class RoundedRectInnerCornerBuilder extends RoundedRectCornerBuilder {
  const RoundedRectInnerCornerBuilder(super.topLeftRadius, super.topRightRadius,
      super.bottomLeftRadius, super.bottomRightRadius,
      {super.orientInwards, super.color});

  @override
  void build(XmlBuilder builder, QrImage image) {
    buildCorner(builder, 0, 0, topLeftRadius, topRightRadius, bottomLeftRadius,
        bottomRightRadius);
    if (orientInwards) {
      buildCorner(builder, image.moduleCount - 7, 0, bottomLeftRadius,
          topLeftRadius, bottomRightRadius, topRightRadius);
      buildCorner(builder, 0, image.moduleCount - 7, topRightRadius,
          bottomRightRadius, topLeftRadius, bottomLeftRadius);
    } else {
      buildCorner(builder, image.moduleCount - 7, 0, topLeftRadius,
          topRightRadius, bottomLeftRadius, bottomRightRadius);
      buildCorner(builder, 0, image.moduleCount - 7, topLeftRadius,
          topRightRadius, bottomLeftRadius, bottomRightRadius);
    }
  }

  void buildCorner(XmlBuilder builder, double x, double y, double tlr,
      double trr, double blr, double brr) {
    builder.element('path', nest: () {
      builder.attribute('fill', color.toSvgString());
      builder.attribute('d',
          'M${x + 2} ${y + 3.5} ${makeArc(x + 2 + tlr, y + 2 + tlr, tlr, 180, 270)} ${makeArc(x + 5 - trr, y + 2 + trr, trr, 270, 360)} ${makeArc(x + 5 - brr, y + 5 - brr, brr, 0, 90)} ${makeArc(x + 2 + blr, y + 5 - blr, blr, 90, 180)} Z');
    });
  }
}
