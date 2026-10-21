import 'package:assistant_presentation/assistant_presentation.dart';
import 'package:calaverita_app/app/app_config.dart';
import 'package:calaverita_app/app/theme.dart';
import 'package:calaverita_data/calaverita_data.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';

/// Composes the calaverita and assistant features into an app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CopilotKit(
      runtimeUrl: AppConfig.runtimeUrl,
      child: MaterialApp(
        title: 'Calaverita Generator',
        theme: buildTheme(),
        home: const CopilotAgentScope(
          agentId: AppConfig.agentId,
          child: CalaveritaModule(
            calaveritasRepository: TemplateCalaveritasRepository(),
            trailingPanel: ChatModule(agentId: AppConfig.agentId),
          ),
        ),
      ),
    );
  }
}
