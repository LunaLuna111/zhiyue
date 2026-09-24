import 'dart:async';

import 'package:flutter/material.dart';

import '../core/session_store.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_theme.dart';

/// Presents server-side logout signals without allowing a failed request to
/// silently destroy the local account session.
class AccountSessionCleanupPrompt extends StatefulWidget {
  const AccountSessionCleanupPrompt({
    super.key,
    required this.session,
    required this.child,
  });

  final SessionStore session;
  final Widget child;

  @override
  State<AccountSessionCleanupPrompt> createState() =>
      _AccountSessionCleanupPromptState();
}

class _AccountSessionCleanupPromptState
    extends State<AccountSessionCleanupPrompt> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_sessionChanged);
    _schedulePresentation();
  }

  @override
  void dispose() {
    widget.session.removeListener(_sessionChanged);
    super.dispose();
  }

  void _sessionChanged() => _schedulePresentation();

  void _schedulePresentation() {
    if (!mounted || _showing || !widget.session.hasPendingAccountCleanup) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_showing && widget.session.hasPendingAccountCleanup) {
        unawaited(_present());
      }
    });
  }

  Future<void> _present() async {
    if (_showing || !widget.session.hasPendingAccountCleanup) return;
    _showing = true;
    final action = await showModalBottomSheet<_CleanupAction>(
      context: context,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CleanupSheet(
        onKeep: () => Navigator.of(context).pop(_CleanupAction.keep),
        onClear: () => Navigator.of(context).pop(_CleanupAction.clear),
      ),
    );
    if (!mounted) return;
    try {
      if (action == _CleanupAction.clear) {
        await widget.session.confirmPendingAccountCleanup();
      } else {
        await widget.session.dismissPendingAccountCleanup();
      }
    } finally {
      _showing = false;
      _schedulePresentation();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _CleanupAction { keep, clear }

class _CleanupSheet extends StatelessWidget {
  const _CleanupSheet({required this.onKeep, required this.onClear});

  final VoidCallback onKeep;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: const ValueKey('account-session-cleanup-sheet'),
      color: ZhPalette.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ZhPalette.subtleInk.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: colors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.zhL10n.accountSessionCheckTitle,
                      key: ValueKey('account-session-cleanup-title'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.zhL10n.accountSessionCheckMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ZhPalette.mutedInk,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.zhL10n.accountSessionCheckDetails,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ZhPalette.subtleInk,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('confirm-account-session-cleanup'),
                  onPressed: onClear,
                  child: Text(context.zhL10n.accountSessionClearKeepBackup),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const ValueKey('keep-account-session'),
                  onPressed: onKeep,
                  child: Text(context.zhL10n.accountSessionKeep),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
