import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrcode_generator/components/color_picker_button.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';

import '../components/expansion_card.dart';

class ColorEdit extends StatelessWidget {
  const ColorEdit({this.group, super.key});
  final ExpansionCardGroup? group;

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      group: group,
      contentPadding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      leading: const CircleAvatar(
        child: Icon(Icons.palette_outlined),
      ),
      title: const Text("Colors"),
      elevation: 2,
      children: [
        Wrap(
          children: [
            ListTile(
              title: const Text('Content'),
              trailing: ColorPickerButton(
                color: Provider.of<StyleModel>(context).outerCornerColor,
                onColorChanged: (c) {
                  Provider.of<StyleModel>(context, listen: false)
                      .setColors(contentColor: c);
                },
              ),
            ),
            ListTile(
              title: const Text("Outer Corners"),
              trailing: ColorPickerButton(
                color: Provider.of<StyleModel>(context).outerCornerColor,
                onColorChanged: (c) {
                  Provider.of<StyleModel>(context, listen: false)
                      .setColors(outerCornerColor: c);
                },
              ),
            ),
            ListTile(
              title: const Text("Inner Corners"),
              trailing: ColorPickerButton(
                color: Provider.of<StyleModel>(context).outerCornerColor,
                onColorChanged: (c) {
                  Provider.of<StyleModel>(context, listen: false)
                      .setColors(innerCornerColor: c);
                },
              ),
            ),
          ],
        ),
        /*Row(
          children: [],
        ),
        Row(
          children: [],
        ),*/
      ],
    );
  }
}
