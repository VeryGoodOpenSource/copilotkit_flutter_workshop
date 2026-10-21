import 'package:calaverita_app/app/theme.dart';
import 'package:calaverita_data/calaverita_data.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';

/// Composes the calaverita feature into an app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calaverita Generator',
      theme: buildTheme(),
      home: const CalaveritaModule(
        calaveritasRepository: TemplateCalaveritasRepository(),
      ),
    );
  }
}
