import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Name, job and tone, and the button that writes the calaverita.
class CalaveritaForm extends StatelessWidget {
  const CalaveritaForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalaveritaCubit>();
    return BlocBuilder<CalaveritaCubit, CalaveritaState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SyncedTextField(
              key: const Key('calaverita_name_field'),
              label: 'Name',
              hint: 'Who is the calaverita for?',
              value: state.draft.name,
              onChanged: cubit.nameChanged,
            ),
            const SizedBox(height: 16),
            _SyncedTextField(
              key: const Key('calaverita_job_field'),
              label: 'Job',
              hint: 'What do they do all day?',
              value: state.draft.job,
              onChanged: cubit.jobChanged,
            ),
            const SizedBox(height: 16),
            SegmentedButton<Tone>(
              key: const Key('calaverita_tone_selector'),
              segments: [
                for (final tone in Tone.values)
                  ButtonSegment(value: tone, label: Text(tone.label)),
              ],
              selected: {state.draft.tone},
              onSelectionChanged: (selection) =>
                  cubit.toneChanged(selection.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('calaverita_generate_button'),
              onPressed: state.canGenerate ? cubit.generate : null,
              icon: state.status == GenerationStatus.generating
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('💀'),
              label: const Text('Write my calaverita'),
            ),
          ],
        );
      },
    );
  }
}

/// A text field that shows [value], even when it changes from outside.
///
/// The text the person types and the [value] stay in step, so whatever sets
/// the state (today the keyboard, later an agent) shows up in the field.
class _SyncedTextField extends StatefulWidget {
  const _SyncedTextField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_SyncedTextField> createState() => _SyncedTextFieldState();
}

class _SyncedTextFieldState extends State<_SyncedTextField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_SyncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
