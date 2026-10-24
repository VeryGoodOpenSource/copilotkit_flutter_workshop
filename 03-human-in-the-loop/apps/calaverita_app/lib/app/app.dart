import 'package:app_ui/app_ui.dart';
import 'package:assistant_presentation/assistant_presentation.dart';
import 'package:calaverita_app/app/app_config.dart';
import 'package:calaverita_data/calaverita_data.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// Composes the calaverita and assistant features into an app.
class App extends StatelessWidget {
  const App({required this.skullArt, super.key});

  /// The SVGs of the skull, loaded at startup.
  final SkullArt skullArt;

  static const _suggestions = [
    'Ana is a pilot, make it sarcastic',
    'Give the skull a sombrero and teal color',
    'Write a calaverita for Mario, a chef',
  ];

  @override
  Widget build(BuildContext context) {
    return CopilotKit(
      runtimeUrl: AppConfig.runtimeUrl,
      headers: AppConfig.headers,
      child: MaterialApp(
        title: 'Calaverita Generator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // One agent for the whole screen: the details and the stage read
        // its shared state, and the chat talks to it.
        home: CopilotAgentScope(
          agentId: AppConfig.agentId,
          child: CalaveritaModule(
            calaveritasRepository: const TemplateCalaveritasRepository(),
            skullArt: skullArt,
            // The tool sits around the chat, so the cards of its calls draw
            // there.
            trailingPanel: const ShowCalaveritaTool(
              child: ChatModule(
                agentId: AppConfig.agentId,
                suggestions: _suggestions,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
