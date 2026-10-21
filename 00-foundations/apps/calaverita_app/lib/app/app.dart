import 'package:app_ui/app_ui.dart';
import 'package:calaverita_data/calaverita_data.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';

/// Composes the calaverita feature into an app.
class App extends StatelessWidget {
  const App({required this.skullArt, super.key});

  /// The SVGs of the skull, loaded at startup.
  final SkullArt skullArt;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calaverita Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: CalaveritaModule(
        calaveritasRepository: const TemplateCalaveritasRepository(),
        skullArt: skullArt,
      ),
    );
  }
}
