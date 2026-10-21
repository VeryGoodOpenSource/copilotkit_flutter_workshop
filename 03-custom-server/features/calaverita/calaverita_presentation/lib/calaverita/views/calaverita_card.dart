import 'package:app_ui/app_ui.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/views/skull_view.dart';

/// A finished calaverita: the verse, and the skull portrait that goes with
/// it.
class CalaveritaCard extends StatelessWidget {
  const CalaveritaCard({
    required this.calaverita,
    this.showPortrait = true,
    super.key,
  });

  final Calaverita calaverita;

  /// Whether the skull is drawn next to the verse. The stage turns it off
  /// because the skull is already there.
  final bool showPortrait;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      color: p.accentWash,
      padding: const EdgeInsets.all(AppSpacing.x4l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.x4l,
        children: [
          if (showPortrait)
            SizedBox(width: 96, child: SkullView(style: calaverita.skull)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calaverita for ${calaverita.name}',
                  style: AppTypography.title.copyWith(color: p.heading),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${calaverita.job} · ${calaverita.tone.label}',
                  style: AppTypography.small.copyWith(color: p.inkTertiary),
                ),
                const Divider(height: AppSpacing.x5l * 2),
                for (final line in calaverita.lines)
                  Text(
                    line,
                    style: AppTypography.body.copyWith(
                      color: p.ink,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
