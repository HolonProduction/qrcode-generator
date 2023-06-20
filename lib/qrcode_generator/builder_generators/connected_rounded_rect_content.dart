import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/content_builders/connected_rounded_rect_content.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/svg_generator.dart';

class ConnectedRoundedRectContentBuilderGenerator
    extends ContentBuilderGenerator {
  final radius = TextEditingController(text: "0.5");

  @override
  ConnectedRoundedRectContentBuilder getBuilder(
      {bool skipCorners = false, Color color = black, int iconCutout = 0}) {
    var r = 0.0;
    if (radius.text.isNotEmpty && double.tryParse(radius.text) != null) {
      r = double.parse(radius.text);
    }
    return ConnectedRoundedRectContentBuilder(
        radius: r,
        skipCorners: skipCorners,
        iconCutout: iconCutout,
        color: color);
  }

  @override
  Widget buildForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: radius,
          decoration: const InputDecoration(labelText: 'Corner radius'),
          style: Theme.of(context).textTheme.bodyMedium,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty ||
                  double.tryParse(newValue.text) != null) {
                return newValue;
              }
              return oldValue;
            })
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
