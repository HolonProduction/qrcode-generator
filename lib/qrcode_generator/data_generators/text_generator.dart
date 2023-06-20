import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content_edit.dart';
import '../qrcode_generator.dart';

class TextGenerator extends DataGenerator {
  const TextGenerator({super.key});

  @override
  Widget buildLabel(BuildContext context) {
    return const Text('Text');
  }

  @override
  Widget buildIcon(BuildContext context) {
    return const Icon(Icons.title_rounded);
  }

  @override
  TextGeneratorState createState() => TextGeneratorState();
}

class TextGeneratorState extends DataGeneratorState<TextGenerator> {
  final TextEditingController controller = TextEditingController();

  @override
  void updateData() {
    Provider.of<ContentModel>(context, listen: false).data = controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => updateData(),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        labelText: 'Text',
      ),
    );
  }
}
