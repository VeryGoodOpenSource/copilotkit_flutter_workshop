import 'dart:math';

/// The one place that says where the agent lives.
///
/// To use the shared hosted backend, change [defaultRuntimeUrl] (or run with
/// `--dart-define=RUNTIME_URL=<url>`).
class AppConfig {
  const AppConfig._();

  /// The Copilot Runtime of the `runtime/` folder of this repository.
  static const defaultRuntimeUrl = 'http://localhost:8200/api/copilotkit';

  /// The Copilot Runtime the app talks to.
  static final Uri runtimeUrl = Uri.parse(
    const String.fromEnvironment(
      'RUNTIME_URL',
      defaultValue: defaultRuntimeUrl,
    ),
  );

  /// The agent the app chats with.
  ///
  /// A runtime can serve several, so a different backend may use another id:
  /// run with `--dart-define=AGENT_ID=<id>`.
  static const agentId = String.fromEnvironment(
    'AGENT_ID',
    defaultValue: 'default',
  );

  /// The password of the shared backend, when it asks for one.
  ///
  /// Run with `--dart-define=WORKSHOP_CODE=<code>`. A local runtime asks for
  /// nothing, so leave it out there.
  static const workshopCode = String.fromEnvironment('WORKSHOP_CODE');

  /// A random id for this run of the app, so a server can tell sessions apart.
  static final String sessionId = _randomId();

  /// The headers sent with every run.
  ///
  /// Custom names on purpose: a runtime answers the browser's preflight with
  /// `Access-Control-Allow-Headers: *`, which covers them but not
  /// `Authorization`. A server that does not know them ignores them.
  static Future<Map<String, String>> headers() async => {
    'X-Workshop-Session': sessionId,
    if (workshopCode.isNotEmpty) 'X-Workshop-Code': workshopCode,
  };

  static String _randomId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
