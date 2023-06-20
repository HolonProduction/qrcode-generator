import 'package:qr/qr.dart';
import 'package:xml/xml.dart';

import '../svg_generator.dart';

class DefaultFrameBuilder extends FrameBuilder {
  const DefaultFrameBuilder();

  @override
  void build(XmlBuilder builder, QrImage image,
      void Function(XmlBuilder builder, QrImage image) buildQrCode) {
    builder.element('svg', nest: () {
      builder.attribute(
          'viewBox', '0 0 ${image.moduleCount} ${image.moduleCount}');
      builder.attribute('xmlns', 'http://www.w3.org/2000/svg');
      buildQrCode(builder, image);
    });
  }
}
