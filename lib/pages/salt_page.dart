import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_reader/universal_reader_flutter.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/content_export_service.dart';
import '../core/json_tools.dart';
import '../core/debug_hooks.dart';
import '../core/privacy_device_profile.dart';
import '../core/salt_bookshelf_store.dart';
import '../core/salt_catalog_store.dart';
import '../core/salt_chapter_cache.dart';
import '../core/salt_chapter_export.dart';
import '../core/salt_manuscript_key.dart';
import '../core/salt_reader_adapter.dart';
import '../core/salt_text_chapter.dart';
import '../core/salt_transport_decoder.dart';
import '../core/tts_service.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import '../widgets/api_views.dart';
import '../widgets/salt_chapter_view.dart';
import 'content_pages.dart';
// The category surface is shared with the home feed's native classify entry.
// Keeping the import here lets the bookshelf's 原版“分类” action land on the
// same implementation instead of maintaining a second divergent page.
import 'feed_page.dart';
import 'web_page.dart';

part 'salt_parts/salt_shared.dart';
part 'salt_parts/salt_value_helpers.dart';
part 'salt_parts/salt_landing.dart';
part 'salt_parts/story_home.dart';
part 'salt_parts/story_modules.dart';
part '../features/shelf/salt_story_support.dart';
part 'salt_parts/product_page.dart';
part 'salt_parts/product_widgets.dart';
part 'salt_parts/product_metadata.dart';
part 'salt_parts/product_header.dart';
part 'salt_parts/reader_page.dart';
part 'salt_parts/reader_loading.dart';
part 'salt_parts/reader_content.dart';
part 'salt_parts/reader_actions.dart';
part 'salt_parts/reader_controls.dart';
part 'salt_parts/reader_result.dart';
part 'salt_parts/reader_decode.dart';
part 'salt_parts/reader_toolbar.dart';
part 'salt_parts/catalog_sheet.dart';
part 'salt_parts/comments_sheet.dart';
