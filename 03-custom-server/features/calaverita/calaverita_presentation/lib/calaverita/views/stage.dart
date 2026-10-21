import 'package:app_ui/app_ui.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_card.dart';
import 'package:calaverita_presentation/calaverita/views/skull_view.dart';

/// The skull as it looks right now, and the calaverita once it is written.
class Stage extends StatelessWidget {
  const Stage({
    required this.skull,
    required this.status,
    this.calaverita,
    this.badge,
    super.key,
  });

  final SkullStyle skull;
  final GenerationStatus status;

  /// The last calaverita written, if any.
  final Calaverita? calaverita;

  /// A small widget in the top left corner, e.g. what the agent is doing.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final calaverita = this.calaverita;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3l,
        children: [
          Expanded(
            child: Center(child: SkullView(style: skull)),
          ),
          if (status == GenerationStatus.failure)
            Text(
              'The skull lost its voice. Try again.',
              textAlign: TextAlign.center,
              style: AppTypography.small.copyWith(color: p.negative),
            )
          else if (calaverita != null)
            CalaveritaCard(calaverita: calaverita, showPortrait: false),
        ],
      ),
    );
  }
}
