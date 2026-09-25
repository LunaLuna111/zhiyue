import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class OpenSourceLicensesPage extends StatelessWidget {
  const OpenSourceLicensesPage({super.key});

  static const _entries = <_LicenseEntry>[
    _LicenseEntry(
      'Flutter',
      'BSD 3-Clause',
      'https://github.com/flutter/flutter',
    ),
    _LicenseEntry('Dart', 'BSD 3-Clause', 'https://github.com/dart-lang/sdk'),
    _LicenseEntry('intl', 'BSD 3-Clause', 'https://pub.dev/packages/intl'),
    _LicenseEntry(
      'zhihu_api',
      'MIT',
      'https://github.com/LunaLuna111/zhihu_api',
    ),
    _LicenseEntry(
      'universal_reader',
      'MIT',
      'https://github.com/LunaLuna111/universal_reader',
    ),
    _LicenseEntry('archive', 'MIT', 'https://pub.dev/packages/archive'),
    _LicenseEntry('crypto', 'BSD 3-Clause', 'https://pub.dev/packages/crypto'),
    _LicenseEntry('html', 'MIT', 'https://pub.dev/packages/html'),
    _LicenseEntry(
      'flutter_secure_storage',
      'BSD 3-Clause',
      'https://pub.dev/packages/flutter_secure_storage',
    ),
    _LicenseEntry('http', 'BSD 3-Clause', 'https://pub.dev/packages/http'),
    _LicenseEntry(
      'liquid_glass_widgets',
      'MIT',
      'https://github.com/sdegenaar/liquid_glass_widgets',
    ),
    _LicenseEntry(
      'path_provider',
      'BSD 3-Clause',
      'https://pub.dev/packages/path_provider',
    ),
    _LicenseEntry('shadcn_ui', 'MIT', 'https://pub.dev/packages/shadcn_ui'),
    _LicenseEntry(
      'shared_preferences',
      'BSD 3-Clause',
      'https://pub.dev/packages/shared_preferences',
    ),
    _LicenseEntry(
      'sqflite',
      'BSD 2-Clause',
      'https://pub.dev/packages/sqflite',
    ),
    _LicenseEntry(
      'url_launcher',
      'BSD 3-Clause',
      'https://pub.dev/packages/url_launcher',
    ),
    _LicenseEntry(
      'video_player',
      'BSD 3-Clause',
      'https://pub.dev/packages/video_player',
    ),
    _LicenseEntry('web', 'BSD 3-Clause', 'https://pub.dev/packages/web'),
    _LicenseEntry(
      'webview_flutter',
      'BSD 3-Clause',
      'https://pub.dev/packages/webview_flutter',
    ),
    _LicenseEntry('xml', 'MIT', 'https://pub.dev/packages/xml'),
  ];

  Future<void> _openProject(BuildContext context, _LicenseEntry entry) async {
    final opened = await launchUrl(
      Uri.parse(entry.url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.zhL10n.settingsOpenSourceLicenseOpenFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final topInset = ZhTopBar.bodyTopInset(context, toolbarHeight: 72);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(
        toolbarHeight: 72,
        title: Text(l10n.settingsOpenSourceLicenses),
      ),
      body: ZhPageWidth(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            ZhSpace.md,
            topInset + ZhSpace.xs,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [
            Text(
              l10n.settingsOpenSourceLicensesIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: ZhSpace.md),
            ZhSurface(
              padding: EdgeInsets.zero,
              radius: 22,
              child: Column(
                children: [
                  for (var index = 0; index < _entries.length; index++) ...[
                    _LicenseTile(
                      entry: _entries[index],
                      onTap: () => _openProject(context, _entries[index]),
                    ),
                    if (index != _entries.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseEntry {
  const _LicenseEntry(this.name, this.license, this.url);

  final String name;
  final String license;
  final String url;
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile({required this.entry, required this.onTap});

  final _LicenseEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 68,
    leading: _LicenseIcon(),
    title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(entry.license),
    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
    onTap: onTap,
  );
}

class _LicenseIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.code_rounded, size: 19, color: ZhPalette.ink),
  );
}
