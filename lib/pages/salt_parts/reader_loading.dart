part of '../salt_page.dart';

extension _SaltReaderLoading on _SaltReaderPageState {
  Future<void> _loadBookshelfState() async {
    try {
      await _bookshelf.load();
      if (mounted) {
        _updateState(
          () => _addedToBookshelf = _bookshelf.contains(widget.businessId),
        );
      }
    } catch (_) {
      // Reading and cached chapters remain available without the shelf DB.
    }
  }

  Future<void> _read({bool bypassCache = false}) async {
    final l10n = context.zhL10n;
    const width = PrivacyDeviceProfile.logicalScreenWidth;
    _updateState(() {
      _loading = true;
      _state = null;
      _decodedContent = null;
      _decodeError = null;
      _textChapter = null;
      _paragraphAnnotations = const {};
      _annotationsError = null;
      _annotationsLoading = false;
      _workDetails = null;
      _catalogNavigation = null;
      _catalogError = null;
      _catalogLoading = false;
      _controlsVisible = false;
    });
    try {
      if (!bypassCache) {
        try {
          final cached = await SaltChapterCache.instance.read(
            businessId: widget.businessId,
            sectionId: widget.sectionId,
          );
          if (cached != null) {
            final manuscript = SaltManuscriptEnvelope.fromJson(
              cached.responseJson,
            );
            final cachedChapter = SaltTextChapter.fromXhtml(
              chapterId: widget.sectionId,
              xhtml: cached.xhtml,
              book: saltReaderBookInfo(
                businessId: widget.businessId,
                manuscript: manuscript,
              ),
              title: manuscript.title,
              index: manuscript.sectionIndex,
            );
            final cachedResponse = ApiResponse(
              uri: widget.api.saltContentUri(
                businessId: widget.businessId,
                sectionId: widget.sectionId,
                windowWidth: width,
              ),
              statusCode: 200,
              bodyBytes: utf8.encode(cached.xhtml).length,
              json: cached.responseJson,
              headers: const {'x-zh-reader-cache': 'hit'},
            );
            if (mounted) {
              _updateState(() {
                _state = cachedResponse;
                _decodedContent = cached.xhtml;
                _textChapter = cachedChapter;
              });
              unawaited(_loadParagraphAnnotations(manuscript));
              if (manuscript.isLong == true ||
                  manuscript.propertyType == 'long_story' ||
                  (manuscript.updatedSectionCount ??
                          manuscript.sectionCount ??
                          0) >
                      1) {
                unawaited(_loadReaderCatalog(manuscript));
              }
              if (_commentTarget(manuscript) == null) {
                unawaited(_loadWorkDetails(width));
              }
            }
            assert(() {
              debugPrint(
                '[zhihu-salt] chapterCache=hit business=${widget.businessId} '
                'section=${widget.sectionId} cachedAt=${cached.cachedAt.toIso8601String()}',
              );
              return true;
            }());
            return;
          }
        } catch (error) {
          assert(() {
            debugPrint('[zhihu-salt] chapterCacheReadFailure=$error');
            return true;
          }());
        }
      }
      var key = await (widget.keyProvider ?? defaultSaltManuscriptKeyProvider())
          .generate();
      assert(() {
        debugPrint(
          '[zhihu-salt] requestKeySha256=${_saltDebugFingerprint(key.rawKey)} '
          'transKeySha256=${_saltDebugFingerprint(key.transKey)} '
          'contract=${widget.contract.name} section=${widget.sectionId}',
        );
        return true;
      }());
      var effectiveContract = widget.contract == SaltReaderContract.automatic
          ? SaltReaderContract.shortContent
          : widget.contract;
      late ApiResponse response;
      SaltArticleCodeEnvelope? codeEnvelope;
      if (effectiveContract == SaltReaderContract.shortContent) {
        response = await widget.api.postSaltJsonUri(
          widget.api.saltContentUri(
            businessId: widget.businessId,
            sectionId: widget.sectionId,
            windowWidth: width,
          ),
          jsonBody: {'trans_key': key.transKey, 'window_width': width},
        );
      } else {
        final codeResponse = await widget.api.postSaltJsonUri(
          widget.api.saltArticleCodeUri(),
          jsonBody: {'section_id': widget.sectionId, 'trans_key': key.transKey},
        );
        if (!codeResponse.isSuccess) {
          if (mounted) {
            _updateState(() {
              _state = codeResponse;
              _loading = false;
            });
          }
          return;
        }
        codeEnvelope = SaltArticleCodeEnvelope.fromJson(codeResponse.json);
        response = await widget.api.getSaltUri(
          widget.api.saltManuCoreUri(
            businessId: widget.businessId,
            sectionId: widget.sectionId,
            windowWidth: width,
          ),
        );
      }

      // `/content` is the primary App 11.4.0 SIP transport. Its response can
      // already contain the `script` payload plus the matching `code` envelope
      // for the same `trans_key`/raw key generated above. Do not discard that
      // bound pair just because the metadata marks the section as a long story:
      // switching to `manu_core` with a separately requested `/manuscript/code`
      // envelope breaks the key/content binding and leads to native -7 / second
      // stage AES failures. Only use the `manu_core` chain as a fallback when
      // `/content` lacks a usable payload envelope.
      if (widget.contract == SaltReaderContract.automatic &&
          response.isSuccess) {
        final preview = SaltManuscriptEnvelope.fromJson(response.json);
        final previewCode = SaltArticleCodeEnvelope.fromJson(
          _saltCode(response.json),
        );
        final hasBoundContent =
            preview.hasScript &&
            (previewCode.articleCode.isNotEmpty ||
                preview.articleCode.isNotEmpty);
        final isLongWork =
            preview.isLong == true || preview.propertyType == 'long_story';
        assert(() {
          debugPrint(
            '[zhihu-salt] autoPreview '
            'isLong=$isLongWork '
            'hasBoundContent=$hasBoundContent '
            'scriptChars=${preview.script?.length ?? 0} '
            'articleCodeChars=${previewCode.articleCode.isNotEmpty ? previewCode.articleCode.length : preview.articleCode.length} '
            'propertyType=${preview.propertyType.isEmpty ? '-' : preview.propertyType}',
          );
          return true;
        }());
        if (!hasBoundContent && isLongWork) {
          effectiveContract = SaltReaderContract.longManuCore;
          key = await (widget.keyProvider ?? defaultSaltManuscriptKeyProvider())
              .generate();
          assert(() {
            debugPrint(
              '[zhihu-salt] autoContract=longManuCore '
              'requestKeySha256=${_saltDebugFingerprint(key.rawKey)} '
              'transKeySha256=${_saltDebugFingerprint(key.transKey)} '
              'section=${widget.sectionId}',
            );
            return true;
          }());
          final codeResponse = await widget.api.postSaltJsonUri(
            widget.api.saltArticleCodeUri(),
            jsonBody: {
              'section_id': widget.sectionId,
              'trans_key': key.transKey,
            },
          );
          if (!codeResponse.isSuccess) {
            if (mounted) {
              _updateState(() {
                _state = codeResponse;
                _loading = false;
              });
            }
            return;
          }
          codeEnvelope = SaltArticleCodeEnvelope.fromJson(codeResponse.json);
          response = await widget.api.getSaltUri(
            widget.api.saltManuCoreUri(
              businessId: widget.businessId,
              sectionId: widget.sectionId,
              windowWidth: width,
            ),
          );
        }
      }
      String? decodedContent;
      String? decodeError;
      SaltTextChapter? textChapter;
      if (response.isSuccess) {
        final manuscript = SaltManuscriptEnvelope.fromJson(response.json);
        final responseCode =
            codeEnvelope ??
            SaltArticleCodeEnvelope.fromJson(_saltCode(response.json));
        final articleCode = responseCode.articleCode.isNotEmpty
            ? responseCode.articleCode
            : manuscript.articleCode;
        final strategy = responseCode.log.isNotEmpty
            ? responseCode.log
            : manuscript.strategy;
        // The endpoint does not normally serialize `random`. The official
        // Android request chain fills CodeResult.random with the same local
        // raw `tk` that produced `trans_key` before it invokes the reader.
        // Prefer an already-hydrated value, otherwise mirror that assignment.
        final decryptRandom = responseCode.random.isNotEmpty
            ? responseCode.random
            : key.rawKey;
        assert(() {
          final requestId = _saltDebugHeader(
            response.headers,
            'x-request-id',
          ).trim();
          final responseFields = _saltDebugResponseFields(response.json);
          debugPrint(
            '[zhihu-salt] scriptChars=${manuscript.script?.length ?? 0} '
            'scriptSha256=${manuscript.script?.isNotEmpty == true ? _saltDebugFingerprint(manuscript.script!) : '-'} '
            'scriptType=${manuscript.scriptType ?? -1} '
            'articleCodeChars=${articleCode.length} '
            'articleCodeSha256=${articleCode.isEmpty ? '-' : _saltDebugFingerprint(articleCode)} '
            'strategyChars=${strategy.length} '
            'strategySha256=${_saltDebugFingerprint(strategy)} '
            'randomChars=${decryptRandom.length} '
            'randomSha256=${decryptRandom.isEmpty ? '-' : _saltDebugFingerprint(decryptRandom)} '
            'contract=${effectiveContract.name} '
            'requiresNativeRenderer=${manuscript.requiresNativeRenderer} '
            'canDecode=${manuscript.canDecodeTransport && articleCode.isNotEmpty && decryptRandom.isNotEmpty} '
            'requestId=${requestId.isEmpty ? '-' : requestId}',
          );
          debugPrint(
            '[zhihu-salt] responseCodeFields='
            '${responseFields.isEmpty ? '<none>' : responseFields.join(' | ')}',
          );
          final transportFields = _saltDebugTransportFields(response.json);
          debugPrint(
            '[zhihu-salt] transportFields='
            '${transportFields.isEmpty ? '<none>' : transportFields.join(' | ')}',
          );
          return true;
        }());
        final directHtml = manuscript.directHtml;
        if (directHtml != null) {
          try {
            textChapter = SaltTextChapter.fromXhtml(
              chapterId: widget.sectionId,
              xhtml: directHtml,
              book: saltReaderBookInfo(
                businessId: widget.businessId,
                manuscript: manuscript,
              ),
              title: manuscript.title,
              index: manuscript.sectionIndex,
            );
            decodedContent = directHtml;
          } on SaltTextChapterException catch (_) {
            decodeError = l10n.saltDecodeFailed;
          }
        } else if (manuscript.canDecodeTransport &&
            articleCode.isNotEmpty &&
            decryptRandom.isNotEmpty) {
          await exportDebugSaltText(
            decodeStatus: 'pending',
            businessId: widget.businessId,
            chapterId: widget.sectionId,
            rawKey: decryptRandom,
            transKey: key.transKey,
            articleCode: articleCode,
            strategy: strategy,
            script: manuscript.script!,
            responseJson: response.json,
            xhtml: '',
            paragraphs: const [],
          );
          try {
            final decodedChapter = await compute(_decodeSaltTextChapter, {
              'chapterId': widget.sectionId,
              'script': manuscript.script!,
              'articleCode': articleCode,
              'strategy': strategy,
              'rawKey': decryptRandom,
            });
            textChapter = decodedChapter.withReaderContext(
              book: saltReaderBookInfo(
                businessId: widget.businessId,
                manuscript: manuscript,
              ),
              title: manuscript.title,
              index: manuscript.sectionIndex,
            );
            decodedContent = decodedChapter.xhtml;
            await exportDebugSaltText(
              decodeStatus: 'success',
              businessId: widget.businessId,
              chapterId: widget.sectionId,
              rawKey: decryptRandom,
              transKey: key.transKey,
              articleCode: articleCode,
              strategy: strategy,
              script: manuscript.script!,
              responseJson: response.json,
              xhtml: decodedChapter.xhtml,
              paragraphs: decodedChapter.paragraphs,
            );
          } on SaltTransportDecodeException catch (error) {
            decodeError = l10n.saltDecodeFailed;
            await exportDebugSaltText(
              decodeStatus: 'failed',
              decodeError: '${error.code}: ${error.message}',
              businessId: widget.businessId,
              chapterId: widget.sectionId,
              rawKey: decryptRandom,
              transKey: key.transKey,
              articleCode: articleCode,
              strategy: strategy,
              script: manuscript.script!,
              responseJson: response.json,
              xhtml: '',
              paragraphs: const [],
            );
            assert(() {
              final diagnostics = error.cause is SaltTransportDiagnostics
                  ? ' diagnostics=${error.cause}'
                  : '';
              debugPrint(
                '[zhihu-salt] decodeFailure=${error.code}$diagnostics',
              );
              return true;
            }());
            if (kDebugMode && error.code == 'invalid_manuscript_padding') {
              final diagnosticValues = {
                'script': manuscript.script!,
                'articleCode': articleCode,
                'strategy': strategy,
                'rawKey': decryptRandom,
              };
              final branchOutcomes = await _diagnoseSaltStrategyBranches(
                diagnosticValues,
              );
              debugPrint('[zhihu-salt] strategyBranches=$branchOutcomes');
            }
          } on SaltTextChapterException catch (error) {
            decodeError = l10n.saltDecodeFailed;
            await exportDebugSaltText(
              decodeStatus: 'failed',
              decodeError: error.toString(),
              businessId: widget.businessId,
              chapterId: widget.sectionId,
              rawKey: decryptRandom,
              transKey: key.transKey,
              articleCode: articleCode,
              strategy: strategy,
              script: manuscript.script!,
              responseJson: response.json,
              xhtml: '',
              paragraphs: const [],
            );
            assert(() {
              debugPrint(
                '[zhihu-salt] textExtractionFailure=${error.cause?.runtimeType}',
              );
              return true;
            }());
          } catch (error, stackTrace) {
            decodeError = l10n.saltDecodeFailed;
            await exportDebugSaltText(
              decodeStatus: 'failed',
              decodeError: '$error\n$stackTrace',
              businessId: widget.businessId,
              chapterId: widget.sectionId,
              rawKey: decryptRandom,
              transKey: key.transKey,
              articleCode: articleCode,
              strategy: strategy,
              script: manuscript.script!,
              responseJson: response.json,
              xhtml: '',
              paragraphs: const [],
            );
            assert(() {
              debugPrint(
                '[zhihu-salt] decodeFailure=${error.runtimeType} '
                'stack=${stackTrace.toString().split('\n').take(5).join(' | ')}',
              );
              return true;
            }());
          }
        } else if (manuscript.canDecodeTransport) {
          decodeError = l10n.saltDecodeParamsMissing;
        }
      }
      if (mounted) {
        _updateState(() {
          _state = response;
          _decodedContent = decodedContent;
          _decodeError = decodeError;
          _textChapter = textChapter;
        });
        if (response.isSuccess && textChapter != null) {
          unawaited(
            _storeChapterInCache(
              response: response,
              manuscript: SaltManuscriptEnvelope.fromJson(response.json),
              chapter: textChapter,
            ),
          );
        }
        if (response.isSuccess) {
          final manuscript = SaltManuscriptEnvelope.fromJson(response.json);
          unawaited(_loadParagraphAnnotations(manuscript));
          if (manuscript.isLong == true ||
              manuscript.propertyType == 'long_story' ||
              (manuscript.updatedSectionCount ?? manuscript.sectionCount ?? 0) >
                  1) {
            unawaited(
              _loadReaderCatalog(manuscript, forceRefresh: bypassCache),
            );
          }
          if (_commentTarget(manuscript) == null) {
            unawaited(_loadWorkDetails(width));
          }
        }
      }
    } catch (error) {
      if (mounted) _updateState(() => _state = error);
    } finally {
      if (mounted) _updateState(() => _loading = false);
    }
  }

  Future<void> _storeChapterInCache({
    required ApiResponse response,
    required SaltManuscriptEnvelope manuscript,
    required SaltTextChapter chapter,
  }) async {
    try {
      await SaltChapterCache.instance.write(
        businessId: widget.businessId,
        sectionId: widget.sectionId,
        title: manuscript.title,
        sectionIndex: manuscript.sectionIndex,
        responseJson: response.json,
        xhtml: chapter.xhtml,
      );
      assert(() {
        debugPrint(
          '[zhihu-salt] chapterCache=stored business=${widget.businessId} '
          'section=${widget.sectionId} paragraphs=${chapter.paragraphs.length}',
        );
        return true;
      }());
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-salt] chapterCacheWriteFailure=$error');
        return true;
      }());
    }
  }

  Future<void> _loadParagraphAnnotations(
    SaltManuscriptEnvelope manuscript,
  ) async {
    if (manuscript.annotationCommentType.isEmpty || !mounted) return;
    _updateState(() {
      _annotationsLoading = true;
      _annotationsError = null;
    });
    try {
      final response = await widget.api.getSaltUri(
        widget.api.saltAnnotationsUri(sectionId: widget.sectionId),
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        _updateState(() => _annotationsError = response);
        return;
      }
      final annotations = saltParagraphAnnotationsOf(response.json);
      _updateState(() {
        _paragraphAnnotations = {
          for (final annotation in annotations)
            annotation.paragraphIndex: annotation,
        };
      });
      assert(() {
        debugPrint(
          '[zhihu-salt] annotations section=${widget.sectionId} '
          'type=${manuscript.annotationCommentType} '
          'rows=${annotations.length} '
          'comments=${annotations.fold<int>(0, (sum, item) => sum + item.commentCount)}',
        );
        return true;
      }());
    } catch (error) {
      if (mounted) _updateState(() => _annotationsError = error);
    } finally {
      if (mounted) _updateState(() => _annotationsLoading = false);
    }
  }

  Future<void> _loadWorkDetails(int width) async {
    if (!mounted) return;
    try {
      final response = await widget.api.getSaltUri(
        widget.api.saltManuCoreUri(
          businessId: widget.businessId,
          sectionId: widget.sectionId,
          windowWidth: width,
        ),
      );
      if (!mounted) return;
      if (!response.isSuccess) return;
      final details = SaltManuscriptEnvelope.fromJson(response.json);
      _updateState(() => _workDetails = details);
      assert(() {
        final target = _commentTarget(details);
        debugPrint(
          '[zhihu-salt] workDetails business=${widget.businessId} '
          'commentType=${target?.$1 ?? '-'} '
          'commentId=${target?.$2 ?? '-'} '
          'commentCount=${details.commentCount ?? -1}',
        );
        return true;
      }());
    } catch (_) {}
  }

  Future<void> _loadReaderCatalog(
    SaltManuscriptEnvelope manuscript, {
    bool forceRefresh = false,
  }) async {
    if (!mounted) return;
    _updateState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final catalog = await SaltCatalogStore.instance.load(
        api: widget.api,
        businessId: widget.businessId,
        forceRefresh: forceRefresh,
      );
      unawaited(
        SaltCatalogStore.instance.markLastRead(
          businessId: widget.businessId,
          sectionId: widget.sectionId,
        ),
      );
      if (!mounted) return;
      final navigation = saltCatalogNavigationOf(
        [catalog.root],
        currentSectionId: widget.sectionId,
        fallbackIndex: manuscript.sectionIndex,
      );
      final readerCatalog = saltReaderCatalog(
        bookId: widget.businessId,
        currentChapterId: widget.sectionId,
        navigation: navigation,
      );
      SaltTextChapter? enrichedChapter;
      final currentChapter = _textChapter;
      if (currentChapter != null) {
        try {
          enrichedChapter = currentChapter.withReaderContext(
            book: saltReaderBookInfo(
              businessId: widget.businessId,
              manuscript: manuscript,
            ),
            catalog: readerCatalog,
            title: manuscript.title,
            index: navigation.currentIndex ?? manuscript.sectionIndex,
          );
        } on SaltTextChapterException catch (error) {
          assert(() {
            debugPrint(
              '[zhihu-salt] readerContextRebindFailure=${error.message}',
            );
            return true;
          }());
        }
      }
      _updateState(() {
        _catalogNavigation = navigation;
        if (enrichedChapter != null) _textChapter = enrichedChapter;
      });
      assert(() {
        debugPrint(
          '[zhihu-salt] catalog section=${widget.sectionId} '
          'index=${navigation.currentIndex ?? -1} '
          'total=${navigation.total ?? -1} '
          'previous=${navigation.previous?.id ?? '-'} '
          'next=${navigation.next?.id ?? '-'} '
          'rows=${navigation.sections.length}',
        );
        return true;
      }());
    } catch (error) {
      if (mounted) _updateState(() => _catalogError = error);
    } finally {
      if (mounted) _updateState(() => _catalogLoading = false);
    }
  }

  (String, String)? _commentTarget(SaltManuscriptEnvelope manuscript) {
    final type = manuscript.commentType.trim();
    final id = manuscript.commentContentId.isNotEmpty
        ? manuscript.commentContentId
        : manuscript.manuscriptId;
    if (!RegExp(r'^[a-z0-9_-]{1,80}$').hasMatch(type) ||
        !RegExp(r'^\d+$').hasMatch(id)) {
      return null;
    }
    return (type, id);
  }

  int? _effectiveSectionCount(SaltManuscriptEnvelope manuscript) =>
      _catalogNavigation?.total ??
      manuscript.updatedSectionCount ??
      _workDetails?.updatedSectionCount ??
      manuscript.sectionCount ??
      _workDetails?.sectionCount;

  int? _effectiveSectionIndex(SaltManuscriptEnvelope manuscript) =>
      _catalogNavigation?.currentIndex ?? manuscript.sectionIndex;

  SaltCatalogSectionInfo? _previousCatalogSection(
    SaltManuscriptEnvelope manuscript,
  ) {
    final catalog = _catalogNavigation?.previous;
    if (catalog != null) return catalog;
    if (manuscript.previousSectionId.isEmpty) return null;
    return SaltCatalogSectionInfo(
      id: manuscript.previousSectionId,
      title: manuscript.previousSectionTitle,
      index: (_effectiveSectionIndex(manuscript) ?? 1) - 1,
    );
  }

  SaltCatalogSectionInfo? _nextCatalogSection(
    SaltManuscriptEnvelope manuscript,
  ) {
    final catalog = _catalogNavigation?.next;
    if (catalog != null) return catalog;
    if (manuscript.nextSectionId.isEmpty) return null;
    return SaltCatalogSectionInfo(
      id: manuscript.nextSectionId,
      title: manuscript.nextSectionTitle,
      index: (_effectiveSectionIndex(manuscript) ?? -1) + 1,
    );
  }
}
