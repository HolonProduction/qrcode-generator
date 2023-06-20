import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  const ColorPickerButton(
      {required this.color, required this.onColorChanged, super.key});
  final Color color;
  final void Function(Color) onColorChanged;

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  Color _currentColor = Colors.black;

  void onColorChanged(Color c) {
    setState(() {
      _currentColor = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    void showPopup() {
      showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: IntrinsicWidth(
                child: SingleChildScrollView(
                  child: ColorPicker(
                    hexInputBar: true,
                    labelTypes: const [],
                    portraitOnly: true,
                    displayThumbColor: true,
                    pickerColor: _currentColor,
                    onColorChanged: onColorChanged,
                  ),
                ),
              ),
            ),
          );
        },
      ).then((value) => widget.onColorChanged(_currentColor));
    }

    return ElevatedButton(
        onPressed: showPopup,
        child: null,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: _currentColor,
        ));
  }
}
