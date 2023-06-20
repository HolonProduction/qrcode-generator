import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qrcode_generator/components/expansion_card.dart';
import 'package:qrcode_generator/qrcode_generator/builder_generators/rounded_rect_corners.dart';
import 'package:qrcode_generator/qrcode_generator/color_edit.dart';
import 'package:qrcode_generator/qrcode_generator/content_edit.dart';
import 'package:qrcode_generator/qrcode_generator/icon_edit.dart';
import 'package:qrcode_generator/qrcode_generator/shape_edit.dart';
import 'package:qrcode_generator/qrcode_generator/svg_generator/svg_generator.dart';
import 'package:universal_html/html.dart' as html;
import 'package:provider/provider.dart';
import 'package:qr/qr.dart';

import 'builder_generators/connected_rounded_rect_content.dart';

enum EditTab { data }

class ContentModel with ChangeNotifier {
  String _data = "";
  String get data => _data;
  set data(String v) {
    _data = v;
    notifyListeners();
  }

  int _errorCorrection = QrErrorCorrectLevel.M;
  int get errorCorrection => _errorCorrection;
  set errorCorrection(int v) {
    _errorCorrection = v;
    notifyListeners();
  }

  bool _iconCutout = false;
  bool get iconCutout => _iconCutout;
  set iconCutout(bool v) {
    _iconCutout = v;
    notifyListeners();
  }

  int determineIconCutout(QrImage code) {
    if (!iconCutout) {
      return 0;
    }

    var errorPercentage = 0.0;
    switch (_errorCorrection) {
      case (QrErrorCorrectLevel.L):
        errorPercentage = 0.07;
      case (QrErrorCorrectLevel.M):
        errorPercentage = 0.15;
      case (QrErrorCorrectLevel.Q):
        errorPercentage = 0.25;
      case (QrErrorCorrectLevel.H):
        errorPercentage = 0.30;
    }
    // Some errors should still be possible.
    errorPercentage *= 0.65;
    var maxCorner = code.moduleCount - 16;
    var maxError =
        sqrt((code.moduleCount * code.moduleCount) * errorPercentage);
    var cutout = min(maxCorner.toInt(), maxError.toInt());
    cutout = cutout % 2 == 0 ? cutout - 1 : cutout;
    return cutout;
  }
}

class StyleModel with ChangeNotifier {
  Color _contentColor = Colors.black;
  Color get contentColor => _contentColor;

  Color _outerCornerColor = Colors.black;
  Color get outerCornerColor => _outerCornerColor;

  Color _innerCornerColor = Colors.black;
  Color get innerCornerColor => _innerCornerColor;

  CornerBuilderGenerator? _innerCornerBuilderGenerator =
      RoundedRectCornerBuilderGenerator(inner: true);
  CornerBuilderGenerator? get innerCornerBuilderGenerator =>
      _innerCornerBuilderGenerator;
  set innerCornerBuilderGenerator(v) {
    _innerCornerBuilderGenerator = v;
    notifyListeners();
  }

  CornerBuilderGenerator? _outerCornerBuilderGenerator =
      RoundedRectCornerBuilderGenerator(inner: false);
  CornerBuilderGenerator? get outerCornerBuilderGenerator =>
      _outerCornerBuilderGenerator;
  set outerCornerBuilderGenerator(v) {
    _outerCornerBuilderGenerator = v;
    notifyListeners();
  }

  ContentBuilderGenerator? _contentBuilderGenerator =
      ConnectedRoundedRectContentBuilderGenerator();
  ContentBuilderGenerator? get contentBuilderGenerator =>
      _contentBuilderGenerator;
  set contentBuilderGenerator(v) {
    _contentBuilderGenerator = v;
    notifyListeners();
  }

  void setColors(
      {Color? contentColor, Color? outerCornerColor, Color? innerCornerColor}) {
    _contentColor = contentColor ?? _contentColor;
    _outerCornerColor = outerCornerColor ?? _outerCornerColor;
    _innerCornerColor = innerCornerColor ?? _innerCornerColor;
    notifyListeners();
  }

  String generate(QrImage image, int iconCutout) {
    return generateQrCodeSvg(image, [
      if (contentBuilderGenerator != null)
        contentBuilderGenerator!.getBuilder(
            skipCorners: true, color: _contentColor, iconCutout: iconCutout),
      if (innerCornerBuilderGenerator != null)
        innerCornerBuilderGenerator!.getBuilder(color: _innerCornerColor),
      if (outerCornerBuilderGenerator != null)
        outerCornerBuilderGenerator!.getBuilder(color: _outerCornerColor),
    ]);
  }
}

abstract class CornerBuilderGenerator with ChangeNotifier {
  CornerBuilder getBuilder({Color color = black});
  Widget buildForm(BuildContext context);
}

abstract class ContentBuilderGenerator with ChangeNotifier {
  ContentBuilder getBuilder(
      {bool skipCorners = false, Color color = black, int iconCutout = 0});
  Widget buildForm(BuildContext context);
}

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final ValueNotifier<String> svgData = ValueNotifier("");
  final ContentModel content = ContentModel();
  final StyleModel style = StyleModel();
  final group = ExpansionCardGroup();

  void generateQrCode() {
    try {
      var qrData = QrImage(
        QrCode.fromData(
            data: content.data, errorCorrectLevel: content.errorCorrection),
      );
      svgData.value =
          style.generate(qrData, content.determineIconCutout(qrData));
    } on InputTooLongException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        content: Text('The inputed data is to large for an QR Code.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StyleModel>.value(
      value: style,
      child: ChangeNotifierProvider<ContentModel>.value(
        value: content,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, BoxConstraints constraints) {
                var cardMinSize = 400.0;
                if (constraints.maxWidth < cardMinSize * 2) {
                  return SingleChildScrollView(
                      child: Column(
                    children: [
                      QrPreviewCard(
                          onGenerate: generateQrCode, svgData: svgData),
                      SettingsList(group: group),
                    ],
                  ));
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: SettingsList(group: group),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                          width: max(
                              cardMinSize, (constraints.maxWidth - 16.0) / 3),
                          child: QrPreviewCard(
                              onGenerate: generateQrCode, svgData: svgData)),
                    ],
                  );
                }
              },
            ),
            /*child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SettingsList(group: group),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: QrPreviewCard(
                            onGenerate: generateQrCode, svgData: svgData),
                      ),
                    ],
                  ),
                ),
              ],
            ),*/
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    generateQrCode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SettingsList extends StatelessWidget {
  const SettingsList({required this.group, super.key});
  final ExpansionCardGroup group;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              contentPadding: const EdgeInsets.all(8),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
      ),
      child: Column(
        children: [
          ContentEdit(group: group),
          ColorEdit(group: group),
          IconEdit(group: group),
          ShapeEdit(group: group),
        ],
      ),
    );
  }
}

class QrPreviewCard extends StatelessWidget {
  const QrPreviewCard(
      {required this.onGenerate, required this.svgData, super.key});
  final void Function() onGenerate;
  final ValueNotifier<String> svgData;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<String>(
                    valueListenable: svgData,
                    builder: (ctx, val, child) => AspectRatio(
                      aspectRatio: 1.0,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(ctx).width,
                        child: svgData.value.isNotEmpty
                            ? SvgPicture.string(val)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: onGenerate,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text("Generate"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (kIsWeb) {
                          var url = html.Url.createObjectUrl(
                            html.Blob([svgData.value], 'image/svg+xml'),
                          );

                          var link = html.document.createElement('a');
                          link.setAttribute(
                            'href',
                            url,
                          );
                          link.setAttribute('download', 'qrcode');
                          link.click();

                          html.Url.revokeObjectUrl(url);
                        } else if (Platform.isLinux ||
                            Platform.isMacOS ||
                            Platform.isWindows) {
                          String? outputFile = await FilePicker.platform
                              .saveFile(
                                  fileName: 'qrcode.svg',
                                  type: FileType.custom,
                                  allowedExtensions: ['svg']);
                          if (outputFile != null) {
                            if (!outputFile.endsWith('.svg')) {
                              outputFile += '.svg';
                            }
                            var file = File(outputFile);
                            file.writeAsString(svgData.value);
                          }
                        }
                      },
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text("SVG"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
