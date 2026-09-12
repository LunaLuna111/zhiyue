part of '../salt_page.dart';

extension _SaltReaderResult on _SaltReaderPageState {
  Future<void> _showReaderSettings() async {
    var draft = _readerSettings;
    var draftFlow = _readerFlow;
    final selected = await showModalBottomSheet<Map<String, Object>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ZhSpace.lg,
              0,
              ZhSpace.lg,
              ZhSpace.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('阅读设置', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                SegmentedButton<SaltReaderFlow>(
                  segments: const [
                    ButtonSegment(
                      value: SaltReaderFlow.vertical,
                      icon: Icon(Icons.view_day_outlined),
                      label: Text('上下滑动'),
                    ),
                    ButtonSegment(
                      value: SaltReaderFlow.paginated,
                      icon: Icon(Icons.view_carousel_outlined),
                      label: Text('左右翻页'),
                    ),
                  ],
                  selected: {draftFlow},
                  onSelectionChanged: (value) =>
                      setSheetState(() => draftFlow = value.first),
                ),
                const SizedBox(height: 18),
                _readerSlider(
                  context,
                  icon: Icons.format_size_rounded,
                  label: '字体大小',
                  valueLabel: '${draft.fontSize.round()}',
                  value: draft.fontSize,
                  min: 14,
                  max: 30,
                  divisions: 16,
                  onChanged: (value) => setSheetState(
                    () => draft = draft.copyWith(fontSize: value),
                  ),
                ),
                _readerSlider(
                  context,
                  icon: Icons.format_line_spacing_rounded,
                  label: '行距',
                  valueLabel: draft.lineHeight.toStringAsFixed(1),
                  value: draft.lineHeight,
                  min: 1.2,
                  max: 2.4,
                  divisions: 12,
                  onChanged: (value) => setSheetState(
                    () => draft = draft.copyWith(lineHeight: value),
                  ),
                ),
                _readerSlider(
                  context,
                  icon: Icons.density_medium_rounded,
                  label: '段距',
                  valueLabel: draft.paragraphSpacing.toStringAsFixed(1),
                  value: draft.paragraphSpacing,
                  min: 0,
                  max: 1.5,
                  divisions: 15,
                  onChanged: (value) => setSheetState(
                    () => draft = draft.copyWith(paragraphSpacing: value),
                  ),
                ),
                _readerSlider(
                  context,
                  icon: Icons.width_normal_rounded,
                  label: '左右边距',
                  valueLabel: '${draft.horizontalMargin.round()}',
                  value: draft.horizontalMargin,
                  min: 8,
                  max: 48,
                  divisions: 10,
                  onChanged: (value) => setSheetState(
                    () => draft = draft.copyWith(horizontalMargin: value),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(
                    sheetContext,
                  ).pop({'settings': draft, 'flow': draftFlow}),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('应用'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    final settings = selected['settings']! as SaltReaderSettings;
    final flow = selected['flow']! as SaltReaderFlow;
    _updateState(() {
      _readerFlow = flow;
      _readerSettings = settings;
    });
  }

  Widget _readerSlider(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) => Column(
    children: [
      Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(label)),
          Text(valueLabel, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    ],
  );

  Widget _result(BuildContext context) {
    final state = _state;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (state == null) return const SizedBox.shrink();
    if (state is! ApiResponse) {
      return ApiErrorView(error: state, onRetry: _read, compact: true);
    }
    if (!state.isSuccess) {
      return ApiErrorView(error: state, onRetry: _read, compact: true);
    }
    final manuscript = SaltManuscriptEnvelope.fromJson(state.json);
    final content =
        _decodedContent ?? manuscript.directHtml ?? htmlContent(state.json);
    final fetchStatus = SaltChapterFetchStatus.fromJson(
      state.json,
      decodedContent: _decodedContent,
      decodeError: _decodeError,
    );
    return ZhSurface(
      backgroundColor: ZhPalette.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '章节信息',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (manuscript.title.isNotEmpty ||
              manuscript.parentTitle.isNotEmpty ||
              manuscript.authorName.isNotEmpty) ...[
            Text(
              manuscript.title.isNotEmpty
                  ? manuscript.title
                  : manuscript.parentTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            if (manuscript.authorName.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                '作者 · ${manuscript.authorName}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
              ),
            ],
            const SizedBox(height: 10),
          ],
          if (manuscript.authenticationResult != null ||
              manuscript.isLocked != null ||
              manuscript.sectionIndex != null ||
              manuscript.sectionCount != null ||
              manuscript.likeCount != null ||
              manuscript.commentCount != null ||
              manuscript.hasTts == true ||
              manuscript.labels.isNotEmpty) ...[
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (manuscript.authenticationResult != null)
                  ZhPill(
                    label: manuscript.authenticationResult! ? '可读' : '未解锁',
                    inverted: manuscript.authenticationResult!,
                  ),
                if (manuscript.isLocked != null)
                  ZhPill(label: manuscript.isLocked! ? '章节锁定' : '章节可读'),
                if (manuscript.sectionIndex != null)
                  ZhPill(
                    label: manuscript.sectionCount == null
                        ? '第 ${manuscript.sectionIndex! + 1} 节'
                        : '第 ${manuscript.sectionIndex! + 1}/${manuscript.sectionCount} 节',
                  ),
                if (manuscript.likeCount != null)
                  ZhPill(label: '${compactCount(manuscript.likeCount!)} 赞'),
                if (manuscript.commentCount != null)
                  ZhPill(label: '${compactCount(manuscript.commentCount!)} 评论'),
                if (manuscript.hasTts == true)
                  const ZhPill(label: '可听', compact: true),
                for (final label in manuscript.labels.take(3))
                  ZhPill(label: label, compact: true),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _chapterFetchStatusCard(
            context,
            fetchStatus,
            bodyDisplayed: _textChapter != null,
          ),
          const SizedBox(height: 12),
          if (content != null && content.trim().isNotEmpty) ...[
            InlineRichContent(html: content),
          ] else if (_textChapter case final chapter?) ...[
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.75,
              child: SaltChapterView(
                chapter: chapter,
                flow: _readerFlow,
                settings: _readerSettings,
                annotations: _paragraphAnnotations,
                onAnnotationTap: (annotation) =>
                    _showAnnotationComments(manuscript, annotation),
              ),
            ),
          ] else if (manuscript.authenticationResult == false ||
              manuscript.isLocked == true) ...[
            Text(
              '当前账号暂无阅读权限',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ] else if (_decodeError case final message?) ...[
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.danger),
            ),
            const SizedBox(height: 10),
            ZhOutlineButton(
              onPressed: _read,
              icon: Icons.refresh_rounded,
              label: '重新加载',
              expand: true,
            ),
          ] else ...[
            const Text('章节内容暂不可用'),
          ],
          if (manuscript.previousSectionId.isNotEmpty ||
              manuscript.nextSectionId.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (manuscript.previousSectionId.isNotEmpty)
                  Expanded(
                    child: ZhOutlineButton(
                      onPressed: () =>
                          _openSection(manuscript.previousSectionId),
                      icon: Icons.arrow_back_rounded,
                      label: manuscript.previousSectionTitle.isEmpty
                          ? '上一节'
                          : manuscript.previousSectionTitle,
                    ),
                  ),
                if (manuscript.previousSectionId.isNotEmpty &&
                    manuscript.nextSectionId.isNotEmpty)
                  const SizedBox(width: 8),
                if (manuscript.nextSectionId.isNotEmpty)
                  Expanded(
                    child: ZhPrimaryButton(
                      onPressed: () => _openSection(manuscript.nextSectionId),
                      icon: Icons.arrow_forward_rounded,
                      label: manuscript.nextSectionTitle.isEmpty
                          ? '下一节'
                          : manuscript.nextSectionTitle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chapterFetchStatusCard(
    BuildContext context,
    SaltChapterFetchStatus status, {
    required bool bodyDisplayed,
  }) {
    final icon = status.hasReadableContent || bodyDisplayed
        ? Icons.article_outlined
        : status.requiresNativeRenderer
        ? Icons.view_in_ar_outlined
        : status.isLocked
        ? Icons.lock_outline_rounded
        : status.hasDecodeError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    final iconColor = status.isLocked || status.hasDecodeError
        ? ZhPalette.danger
        : ZhPalette.ink;
    final chips = <Widget>[
      const ZhPill(label: '资料已获取', compact: true),
      if (status.isAuthorized) const ZhPill(label: '权益通过', compact: true),
      if (status.hasBoundPayload) const ZhPill(label: '载荷已获取', compact: true),
      if (status.hasReadableContent || bodyDisplayed)
        const ZhPill(label: '正文已显示', compact: true),
      if (status.requiresNativeRenderer && !bodyDisplayed)
        const ZhPill(label: '等待正文解析', compact: true),
      if (status.scriptType != null)
        ZhPill(label: 'type ${status.scriptType}', compact: true),
      if (status.scriptChars > 0)
        ZhPill(
          label: '${compactCount(status.scriptChars)} 字符载荷',
          compact: true,
        ),
      if (status.articleCodeChars > 0)
        ZhPill(label: '${status.articleCodeChars} 位 code', compact: true),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZhPalette.background,
        border: Border.all(color: ZhPalette.border),
        borderRadius: BorderRadius.circular(ZhRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bodyDisplayed ? '章节正文已显示' : status.primaryLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bodyDisplayed
                          ? '章节资料、绑定载荷和完整正文均已就绪。'
                          : status.secondaryLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: status.isLocked || status.hasDecodeError
                            ? ZhPalette.danger
                            : ZhPalette.mutedInk,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 7, runSpacing: 7, children: chips),
          ],
        ],
      ),
    );
  }

  void _openSection(String sectionId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SaltReaderPage(
          api: widget.api,
          businessId: widget.businessId,
          sectionId: sectionId,
          contract: widget.contract,
          layoutSettings: _readerSettings,
          readerFlow: _readerFlow,
        ),
      ),
    );
  }
}
