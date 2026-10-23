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
}
