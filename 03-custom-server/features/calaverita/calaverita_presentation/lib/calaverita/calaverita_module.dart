import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/skull/skull_art.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// The calaverita screen with everything it needs.
///
/// It must sit below a `CopilotAgentScope`: the form is the agent's shared
/// state.
class CalaveritaModule extends StatelessWidget {
  const CalaveritaModule({
    required this.calaveritasRepository,
    required this.skullArt,
    this.trailingPanel,
    super.key,
  });

  final ICalaveritasRepository calaveritasRepository;

  /// The SVGs of the skull, loaded with [SkullArt.load].
  final SkullArt skullArt;

  /// Filled by the app: a panel beside the stage (below it on a narrow
  /// screen).
  final Widget? trailingPanel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ICalaveritasRepository>.value(value: calaveritasRepository),
        Provider<SkullArt>.value(value: skullArt),
      ],
      child: BlocProvider(
        create: (context) =>
            CalaveritaCubit(calaveritasRepository: context.read()),
        child: CalaveritaPage(trailingPanel: trailingPanel),
      ),
    );
  }
}
