import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr/qr.dart';

import 'data_generators/text_generator.dart';
import 'data_generators/wifi_generator.dart';
import '../components/expansion_card.dart';
import 'qrcode_generator.dart';

class ContentEdit extends StatelessWidget {
  const ContentEdit({this.group, super.key});
  final ExpansionCardGroup? group;

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      group: group,
      elevation: 2,
      leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
      title: const Text("Content"),
      contentPadding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      children: [
        ListTile(
          title: const Text('Error correction level'),
          trailing: Builder(
            builder: (ctx) => SegmentedButton<int>(
                showSelectedIcon: false,
                onSelectionChanged: (p) {
                  Provider.of<ContentModel>(ctx, listen: false)
                      .errorCorrection = p.first;
                },
                segments: QrErrorCorrectLevel.levels
                    .map<ButtonSegment<int>>((e) => ButtonSegment<int>(
                        value: e, label: Text(QrErrorCorrectLevel.getName(e))))
                    .toList(),
                selected: <int>{
                  Provider.of<ContentModel>(ctx).errorCorrection
                }),
          ),
        ),
        DataEdit(generators: [
          TextGenerator(key: GlobalKey<TextGeneratorState>()),
          WifiGenerator(key: GlobalKey<WifiGeneratorState>()),
        ]),
      ],
    );
  }
}

class DataEdit extends StatefulWidget {
  const DataEdit({required this.generators, super.key});
  final List<DataGenerator> generators;

  @override
  State<DataEdit> createState() => _DataEditState();
}

class _DataEditState extends State<DataEdit> {
  int _selectedGenerator = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Data'),
          trailing: SegmentedButton<int>(
            showSelectedIcon: false,
            onSelectionChanged: (p0) {
              setState(() {
                _selectedGenerator = p0.first;
              });
              (widget.generators[_selectedGenerator].key
                      as GlobalKey<DataGeneratorState>)
                  .currentState!
                  .updateData();
            },
            selected: <int>{_selectedGenerator},
            segments: widget.generators
                .asMap()
                .map<int, ButtonSegment<int>>(
                  (key, value) => MapEntry(
                    key,
                    ButtonSegment<int>(
                      value: key,
                      label: value.buildLabel(context),
                      icon: value.buildIcon(context),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: IndexedStack(
            index: _selectedGenerator,
            children: widget.generators
                .asMap()
                .map<int, Widget>((key, value) => MapEntry(
                    key,
                    SizedBox(
                      height: key == _selectedGenerator ? null : 1,
                      child: value,
                    )))
                .values
                .toList(),
          ),
        ),
      ],
    );
  }
}

abstract class DataGenerator extends StatefulWidget {
  const DataGenerator({super.key});

  Widget buildLabel(BuildContext context);
  Widget buildIcon(BuildContext context);

  @override
  DataGeneratorState createState();
}

abstract class DataGeneratorState<T extends DataGenerator> extends State<T> {
  void updateData();
}
