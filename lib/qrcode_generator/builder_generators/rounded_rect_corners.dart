import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/corner_builders/rounded_rect_corners.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/svg_generator.dart';

class RoundedRectCornerBuilderGenerator extends CornerBuilderGenerator {
  RoundedRectCornerBuilderGenerator({required this.inner});
  final bool inner;
  bool inwards = true;
  final radiusTopLeft = TextEditingController(text: "0.5");
  final radiusTopRight = TextEditingController(text: "0.5");
  final radiusBottomLeft = TextEditingController(text: "0.5");
  final radiusBottomRight = TextEditingController(text: "0.5");

  @override
  Widget buildForm(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          onChanged: (value) {
            inwards = value!;
            notifyListeners();
          },
          value: inwards,
          title: const Text("Rotate inwards"),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: radiusTopLeft,
                decoration: const InputDecoration(labelText: 'Radius top left'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: radiusTopRight,
                decoration:
                    const InputDecoration(labelText: 'Radius top right'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: radiusBottomLeft,
                decoration:
                    const InputDecoration(labelText: 'Radius bottom left'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: radiusBottomRight,
                decoration:
                    const InputDecoration(labelText: 'Radius bottom right'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  CornerBuilder getBuilder({Color color = black}) {
    double rtl = double.tryParse(radiusTopLeft.text) ?? 0.0;
    double rtr = double.tryParse(radiusTopRight.text) ?? 0.0;
    double rbl = double.tryParse(radiusBottomLeft.text) ?? 0.0;
    double rbr = double.tryParse(radiusBottomRight.text) ?? 0.0;

    if (inner) {
      return RoundedRectInnerCornerBuilder(rtl, rtr, rbl, rbr,
          color: color, orientInwards: inwards);
    } else {
      return RoundedRectOuterCornerBuilder(rtl, rtr, rbl, rbr,
          color: color, orientInwards: inwards);
    }
  }
}
