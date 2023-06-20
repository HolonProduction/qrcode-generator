import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content_edit.dart';
import '../qrcode_generator.dart';

class WifiGenerator extends DataGenerator {
  const WifiGenerator({super.key});

  @override
  Widget buildLabel(BuildContext context) {
    return const Text('WLAN');
  }

  @override
  Widget buildIcon(BuildContext context) {
    return const Icon(Icons.wifi_rounded);
  }

  @override
  WifiGeneratorState createState() => WifiGeneratorState();
}

class WifiGeneratorState extends DataGeneratorState<WifiGenerator> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  bool encrypted = true;
  bool hidden = false;

  @override
  void updateData() {
    Provider.of<ContentModel>(context, listen: false).data =
        'WIFI:${encrypted ? 'T:WPA;' : ''}S:${ssidController.text};${hidden ? 'H:true;' : ''}${encrypted ? 'P:${pwController.text};' : ''};';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IntrinsicHeight(
            child: Column(
              children: [
                TextField(
                  controller: ssidController,
                  onChanged: (_) => updateData(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    labelText: 'Name (SSID)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pwController,
                  onChanged: (_) => updateData(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: IntrinsicHeight(
            child: Column(
              children: [
                CheckboxListTile(
                    title: const Text('Encrypted'),
                    value: encrypted,
                    onChanged: (value) {
                      setState(() {
                        encrypted = value ?? false;
                      });
                      updateData();
                    }),
                const SizedBox(height: 8),
                CheckboxListTile(
                    title: const Text('Hidden'),
                    value: hidden,
                    onChanged: (value) {
                      setState(() {
                        hidden = value ?? false;
                      });
                      updateData();
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
