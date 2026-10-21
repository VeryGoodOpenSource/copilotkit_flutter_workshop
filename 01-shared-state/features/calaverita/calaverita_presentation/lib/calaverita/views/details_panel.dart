import 'package:app_ui/app_ui.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/views/skull_controls.dart';
import 'package:calaverita_presentation/calaverita/views/synced_text_field.dart';

/// The form: who the calaverita is for, how it sounds and how the skull
/// looks, and the button that writes it.
///
/// It draws the [draft] it is given and reports what the person does through
/// callbacks, so it doesn't care where the draft lives.
class DetailsPanel extends StatelessWidget {
  const DetailsPanel({
    required this.draft,
    required this.canGenerate,
    required this.isGenerating,
    required this.onNameChanged,
    required this.onJobChanged,
    required this.onToneChanged,
    required this.onSkullPartChanged,
    required this.onSkullColorChanged,
    required this.onGenerate,
    super.key,
  });

  final CalaveritaDraft draft;
  final bool canGenerate;
  final bool isGenerating;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onJobChanged;
  final ValueChanged<Tone> onToneChanged;
  final void Function(SkullPart part, String variant) onSkullPartChanged;
  final ValueChanged<String> onSkullColorChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Details',
      icon: AppIcons.package,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x3l,
                0,
                AppSpacing.x3l,
                AppSpacing.x3l,
              ),
              children: [
                SyncedTextField(
                  key: const Key('calaverita_name_field'),
                  label: 'Name',
                  hint: 'Who is the calaverita for?',
                  value: draft.name,
                  onChanged: onNameChanged,
                ),
                const SizedBox(height: AppSpacing.xl),
                SyncedTextField(
                  key: const Key('calaverita_job_field'),
                  label: 'Job',
                  hint: 'What do they do all day?',
                  value: draft.job,
                  onChanged: onJobChanged,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppSegmented<Tone>(
                  key: const Key('calaverita_tone_selector'),
                  segments: {for (final tone in Tone.values) tone: tone.label},
                  value: draft.tone,
                  onChanged: onToneChanged,
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.x4l),
                SkullControls(
                  style: draft.skull,
                  onPartChanged: onSkullPartChanged,
                  onColorChanged: onSkullColorChanged,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x3l),
            child: AppButton.primary(
              key: const Key('calaverita_generate_button'),
              label: isGenerating ? 'Writing…' : 'Write my calaverita',
              icon: AppIcons.sparkle,
              expanded: true,
              onPressed: canGenerate ? onGenerate : null,
            ),
          ),
        ],
      ),
    );
  }
}
