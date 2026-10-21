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

  /// The agent of the runtime the app chats with.
  static const agentId = 'default';
}
