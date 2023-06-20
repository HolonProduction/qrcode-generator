import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRCode Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QRCode Generator"),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff24292f),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    launchUrlString(
                        "https://github.com/HolonProduction/qrcode-generator");
                  },
                  icon: const Icon(Icons.star_rounded),
                  label: const Text("Github"),
                ),
                const SizedBox(width: 8),
                KofiButton(
                  style: FilledButton.styleFrom(foregroundColor: Colors.white),
                  text: "Buy me a coffe",
                  kofiName: "HolonProduction",
                  kofiColor: KofiColor.Red,
                ),
                const SizedBox(
                  width: 8,
                ),
                IconButton(
                    onPressed: () {
                      PackageInfo.fromPlatform().then((packageInfo) {
                        showAboutDialog(
                          applicationIcon: SvgPicture.asset('assets/icon.svg'),
                          context: context,
                          applicationVersion: packageInfo.version,
                          children: [
                            const Text(
                                "This QRCode Generator was build with privacy in mind. All data you enter is processed on you PC. This can be useful when creating QRCodes with sensitive information like WLAN passwords.")
                          ],
                        );
                      });
                    },
                    icon: const Icon(Icons.help_rounded))
              ],
            ),
          )
        ],
      ),
      body: const QRCodeGenerator(),
    );
  }
}
