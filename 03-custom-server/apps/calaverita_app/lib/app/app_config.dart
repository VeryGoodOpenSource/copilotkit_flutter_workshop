/// The one place that says where the agent lives.
///
/// To use a hosted server, change [defaultRuntimeUrl] (or run with
/// `--dart-define=RUNTIME_URL=<url>`).
class AppConfig {
  const AppConfig._();

  /// The Copilot Runtime of the `server/` folder of this step.
  static const defaultRuntimeUrl = 'http://localhost:4100/api/copilotkit';

  /// The Copilot Runtime the app talks to.
  static final Uri runtimeUrl = Uri.parse(
    const String.fromEnvironment(
      'RUNTIME_URL',
      defaultValue: defaultRuntimeUrl,
    ),
  );

  /// The agent of the server the app chats with.
  static const agentId = 'calaverita';
}
