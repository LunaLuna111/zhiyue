import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhihu_api/zhihu_api.dart';
import 'package:zhiyue_client/core/session_store.dart';
import 'package:zhiyue_client/widgets/account_session_cleanup_prompt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ApiSessionCleanupRequest requestFor(SessionStore session) =>
      ApiSessionCleanupRequest(
        reason: 'test session rejection',
        source: 'test',
        credentialRevision: session.credentialRevision,
        statusCode: 401,
        businessCode: '100008',
      );

  SessionStore loggedInSession() => SessionStore()
    ..authorization = 'Bearer test-access'
    ..refreshToken = 'test-refresh'
    ..udid = 'test-udid'
    ..sessionKind = 'account';

  test('server logout is pending until the user chooses an action', () async {
    final session = loggedInSession();

    expect(
      await session.requestAccountSessionCleanup(requestFor(session)),
      isTrue,
    );
    expect(session.hasPendingAccountCleanup, isTrue);
    expect(session.hasAccountSession, isTrue);
    expect(session.sessionLabel, '登录状态待确认');

    await session.dismissPendingAccountCleanup();

    expect(session.hasPendingAccountCleanup, isFalse);
    expect(session.hasAccountSession, isTrue);
  });

  test(
    'confirmed cleanup clears the active session without a silent request',
    () async {
      final session = loggedInSession();
      await session.requestAccountSessionCleanup(requestFor(session));

      expect(await session.confirmPendingAccountCleanup(), isTrue);
      expect(session.hasPendingAccountCleanup, isFalse);
      expect(session.hasAccountSession, isFalse);
      expect(session.authorization, isEmpty);
      expect(session.refreshToken, isEmpty);
    },
  );

  testWidgets('cleanup signal opens the non-dismissible bottom sheet', (
    tester,
  ) async {
    final session = loggedInSession();
    await session.requestAccountSessionCleanup(requestFor(session));

    await tester.pumpWidget(
      MaterialApp(
        home: AccountSessionCleanupPrompt(
          session: session,
          child: const Scaffold(body: Text('content')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('account-session-cleanup-sheet')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('keep-account-session')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('keep-account-session')));
    await tester.pumpAndSettle();

    expect(session.hasPendingAccountCleanup, isFalse);
    expect(session.hasAccountSession, isTrue);
  });
}
