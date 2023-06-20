import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrcode_generator/components/expansion_card.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';

class IconEdit extends StatelessWidget {
  const IconEdit({this.group, super.key});
  final ExpansionCardGroup? group;

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      group: group,
      title: const Text("Icon"),
      contentPadding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      elevation: 2,
      leading: const CircleAvatar(child: Icon(Icons.image_outlined)),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
              "Embedding icons is currently not possible. Use an vector graphic editor like Inkscape for that."),
        ),
        CheckboxListTile(
          value: Provider.of<ContentModel>(context).iconCutout,
          onChanged: (v) {
            Provider.of<ContentModel>(context, listen: false).iconCutout = v!;
          },
          title: const Text("Leave empty space for icon"),
        ),
      ],
    );
  }
}
