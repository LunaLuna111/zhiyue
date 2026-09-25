import 'package:zhihu_api/zhihu_api.dart'
    show NegativeFeedbackIdentity, unwrapObject;

// Compatibility export. The reusable implementation lives in `zhihu_api`.
export 'package:zhihu_api/zhihu_api.dart'
    show
        BlockKeywordsConfig,
        NegativeFeedbackAction,
        NegativeFeedbackIdentity,
        NegativeFeedbackMenu,
        NegativeFeedbackMenuItem;

/// Builds the feedback identity from the same normalized object used by feed
/// cards and detail routing.
///
/// Feed responses are not consistent about where the post identity lives:
/// ordinary rows can put `type`/`id` at the top level while recommendation
/// wrappers keep them inside `object`, `target`, or a component card. The API
/// package's compatibility factory intentionally stays small, so the client
/// merges its normalized projection before asking that factory to validate the
/// identity. Without this, long-pressing those rows silently returned before
/// the feedback sheet was shown.
NegativeFeedbackIdentity negativeFeedbackIdentityFromFeed(
  Map<String, dynamic> source,
) {
  final object = unwrapObject(source);
  return NegativeFeedbackIdentity.fromFeed({...source, ...object});
}
