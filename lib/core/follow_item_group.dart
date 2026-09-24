import 'json_tools.dart';

bool isFollowItemGroupRow(Map<String, dynamic> row) {
  for (final candidate in [row, unwrapObject(row)]) {
    final marker = plainText(candidate['type']).trim().toLowerCase();
    if (marker == 'item_group_card') return true;
  }
  return false;
}

List<Map<String, dynamic>> followItemGroupChildren(Map<String, dynamic> row) {
  final object = unwrapObject(row);
  final rawChildren = object['data'];
  if (rawChildren is! List) return const [];

  return rawChildren
      .whereType<Map>()
      .map((rawChild) {
        final child = rawChild.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final childType = plainText(child['type']).trim().toLowerCase();
        if (childType == 'people' || childType == 'member') {
          final rawProfile = child['card_extend_data'];
          if (rawProfile is Map) {
            final profile = rawProfile.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            // OtherActionSub is only a transport shell for people rows. The
            // official client renders the People object stored here instead
            // of exposing the shell's wire type as the title.
            child.addAll(profile);
            child['type'] = childType;
            final profileId = plainText(profile['id']);
            final profileToken = plainText(profile['url_token']);
            if (profileId.isNotEmpty || profileToken.isNotEmpty) {
              child['id'] = profileId.isNotEmpty ? profileId : profileToken;
            }
          }
          if (plainText(child['name']).isEmpty) {
            for (final key in const [
              'user_name',
              'userName',
              'nickname',
              'full_name',
            ]) {
              final name = plainText(child[key]);
              if (name.isNotEmpty) {
                child['name'] = name;
                break;
              }
            }
          }
        }
        final author = child['author'];
        if (author is String && plainText(author).isNotEmpty) {
          child['author'] = <String, dynamic>{
            'name': plainText(author),
            if (plainText(child['author_url']).isNotEmpty)
              'url': child['author_url'],
          };
        }
        if (plainText(child['excerpt']).isEmpty) {
          final digest = plainText(child['digest']);
          if (digest.isNotEmpty) child['excerpt'] = digest;
        }
        if (plainText(child['image_url']).isEmpty) {
          final imageUrl = plainText(child['img_url']);
          if (imageUrl.isNotEmpty) child['image_url'] = imageUrl;
        }
        return child;
      })
      .toList(growable: false);
}

int followItemGroupInitialSize(
  Map<String, dynamic> row, {
  required int childCount,
}) {
  if (childCount <= 0) return 0;
  final raw = unwrapObject(row)['unfold_show_size'];
  final value = raw is num ? raw.toInt() : int.tryParse(plainText(raw));
  return (value ?? 1).clamp(1, childCount).toInt();
}
