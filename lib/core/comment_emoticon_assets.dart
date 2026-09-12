import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'comment_emoticons.dart';

const _catalogs = <({String xml, String id, String type})>[
  (xml: 'assets/emoji/emoji.xml', id: 'EMOJI_GROUP_ID', type: 'official'),
  (xml: 'assets/emoji/vip_emoji.xml', id: 'VIP_EMOJI_GROUP_ID', type: 'vip'),
];

Future<List<CommentEmoticonGroup>>? _bundledCatalogCache;
Future<Map<String, CommentEmoticon>>? _bundledLookupCache;
Map<String, CommentEmoticon> _loadedBundledLookup = const {};

Map<String, CommentEmoticon> get bundledCommentEmoticonLookup =>
    _loadedBundledLookup;

Future<List<CommentEmoticonGroup>> loadBundledCommentEmoticonGroups() =>
    _bundledCatalogCache ??= _loadBundledCommentEmoticonGroups();

/// Resolves the bracket token used in comment text to its APK-bundled image.
///
/// The original client checks the default catalog first and only then the VIP
/// catalog. `putIfAbsent` preserves that behavior for duplicate titles such as
/// `[感谢]` and `[哇]` while keeping the lookup entirely local and offline.
Future<Map<String, CommentEmoticon>> loadBundledCommentEmoticonLookup() =>
    _bundledLookupCache ??= loadBundledCommentEmoticonGroups().then((groups) {
      final result = <String, CommentEmoticon>{};
      for (final group in groups) {
        for (final emoticon in group.emoticons) {
          if (emoticon.assetImagePath.isNotEmpty) {
            for (final key in commentEmoticonLookupKeys(emoticon.title)) {
              result.putIfAbsent(key, () => emoticon);
            }
          }
        }
      }
      return _loadedBundledLookup = Map<String, CommentEmoticon>.unmodifiable(
        result,
      );
    });

Future<List<CommentEmoticonGroup>> _loadBundledCommentEmoticonGroups() async {
  final groups = await Future.wait(_catalogs.map(_loadCatalog));
  return groups.where((group) => group.emoticons.isNotEmpty).toList();
}

Future<CommentEmoticonGroup> _loadCatalog(
  ({String xml, String id, String type}) source,
) async {
  final document = XmlDocument.parse(await rootBundle.loadString(source.xml));
  final catalog = document.findAllElements('Catalog').first;
  final directory = _assetPath(catalog.getAttribute('dir') ?? '');
  final icon = '$directory${catalog.getAttribute('TabIcon') ?? ''}';
  final selectedIcon =
      '$directory${catalog.getAttribute('SelectedTabIcon') ?? ''}';
  final emoticons = catalog
      .findElements('Emoticon')
      .map(
        (element) => CommentEmoticon(
          id: element.getAttribute('ID') ?? '',
          title: element.getAttribute('Tag') ?? '',
          groupId: source.id,
          groupType: source.type,
          staticImageUrl: '',
          dynamicImageUrl: '',
          stickerType: source.type == 'vip' ? 2 : 1,
          status: 1,
          assetImagePath: '$directory${element.getAttribute('File') ?? ''}',
        ),
      )
      .where((value) => value.id.isNotEmpty && value.title.isNotEmpty)
      .toList(growable: false);
  return CommentEmoticonGroup(
    id: source.id,
    title: catalog.getAttribute('Title') ?? '表情',
    type: source.type,
    iconUrl: '',
    selectedIconUrl: '',
    version: int.tryParse(catalog.getAttribute('Version') ?? '') ?? 0,
    emoticons: emoticons,
    assetIconPath: icon,
    assetSelectedIconPath: selectedIcon,
  );
}

String _assetPath(String value) {
  final normalized = value.trim().replaceAll('\\', '/');
  if (normalized.isEmpty ||
      normalized.startsWith('/') ||
      normalized.contains('..')) {
    return 'assets/emoji/default/';
  }
  return normalized.startsWith('assets/') ? normalized : 'assets/$normalized';
}
