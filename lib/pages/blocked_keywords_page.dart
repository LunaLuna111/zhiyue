import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/negative_feedback.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class BlockedKeywordsPage extends StatefulWidget {
  const BlockedKeywordsPage({
    super.key,
    required this.api,
    required this.identity,
  });

  final ZhihuApiClient api;
  final NegativeFeedbackIdentity identity;

  @override
  State<BlockedKeywordsPage> createState() => _BlockedKeywordsPageState();
}

class _BlockedKeywordsPageState extends State<BlockedKeywordsPage> {
  final _controller = TextEditingController();
  BlockKeywordsConfig? _config;
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await widget.api.getBlockedKeywords(
        sceneCode: widget.identity.sceneCode,
      );
      if (!response.isSuccess) throw response;
      final config = BlockKeywordsConfig.fromJson(response.json);
      if (mounted) setState(() => _config = config);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final config = _config;
    final value = _controller.text.trim();
    if (config == null || _saving) return;
    if (value.runes.length < config.minLength ||
        value.runes.length > config.maxLength) {
      _message('关键词需为 ${config.minLength}-${config.maxLength} 个字符');
      return;
    }
    if (config.keywords.contains(value)) {
      _message('该关键词已经存在');
      return;
    }
    if (config.keywords.length >= config.maxCount) {
      _message('最多可设置 ${config.maxCount} 个关键词');
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await widget.api.addBlockedKeyword(
        identity: widget.identity,
        keyword: value,
      );
      if (!response.isSuccess) throw response;
      if (!mounted) return;
      final next = [...config.keywords, value];
      _controller.clear();
      setState(
        () => _config = BlockKeywordsConfig(
          keywords: next,
          isVip: config.isVip,
          minLength: config.minLength,
          maxLength: config.maxLength,
          maxCount: config.maxCount,
        ),
      );
    } catch (error) {
      if (mounted) _message(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String keyword) async {
    final config = _config;
    if (config == null || _saving) return;
    setState(() => _saving = true);
    try {
      final response = await widget.api.deleteBlockedKeyword(
        keyword,
        sceneCode: widget.identity.sceneCode,
      );
      if (!response.isSuccess) throw response;
      if (!mounted) return;
      setState(
        () => _config = BlockKeywordsConfig(
          keywords: config.keywords.where((item) => item != keyword).toList(),
          isVip: config.isVip,
          minLength: config.minLength,
          maxLength: config.maxLength,
          maxCount: config.maxCount,
        ),
      );
    } catch (error) {
      if (mounted) _message(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _errorMessage(Object error) => error is ApiResponse
      ? error.failure.detail
      : ApiFailure.from(error).detail;

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('屏蔽关键词')),
    body: SafeArea(child: _body()),
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block_rounded, size: 42),
              const SizedBox(height: 16),
              Text(_errorMessage(_error!), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ZhOutlineButton(
                onPressed: _load,
                icon: Icons.refresh_rounded,
                label: '重试',
              ),
            ],
          ),
        ),
      );
    }
    final config = _config!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Text('包含这些关键词的推荐将被减少', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '已设置 ${config.keywords.length}/${config.maxCount}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: '${config.minLength}-${config.maxLength} 个字符',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _saving ? null : _add,
              tooltip: '添加关键词',
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (config.keywords.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text('暂未设置屏蔽关键词')),
          )
        else
          ...config.keywords.map(
            (keyword) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(keyword),
              trailing: IconButton(
                onPressed: _saving ? null : () => _delete(keyword),
                tooltip: '删除 $keyword',
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
      ],
    );
  }
}
