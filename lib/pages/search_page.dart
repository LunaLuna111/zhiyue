import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import '../core/api_client.dart';
import '../core/input_validation.dart';
import '../core/json_tools.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import '../widgets/api_views.dart';
import 'content_pages.dart';
import 'my_page.dart';
import 'salt_page.dart';
import 'web_page.dart';

part 'search_parts/search_page.dart';
part 'search_parts/search_results.dart';
part 'search_parts/result_cards.dart';
part 'search_parts/result_sections.dart';
part 'search_parts/result_content_cards.dart';
part 'search_parts/entity_result_cards.dart';
part 'search_parts/search_controls.dart';
part 'search_parts/search_suggestions.dart';

/// Coordinates activation of the persistent search page in the home shell.
///
/// The shell keeps every bottom-navigation page alive, so `autofocus` only
/// runs during the first widget mount. Incrementing this controller when the
/// search destination is selected gives the page a route-like activation
/// event without rebuilding or replacing its state.
class SearchPageController extends ChangeNotifier {
  int _activation = 0;

  int get activation => _activation;

  void activate() {
    _activation += 1;
    notifyListeners();
  }
}
