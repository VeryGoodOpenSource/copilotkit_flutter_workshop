import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Name, job and tone, and the button that writes the calaverita.
///
/// The fields show the agent's shared state, so the agent can fill them in,
/// and typing edits that same state.
class CalaveritaForm extends StatefulWidget {
  const CalaveritaForm({super.key});

  @override
  State<CalaveritaForm> createState() => _CalaveritaFormState();
}

class _CalaveritaFormState extends State<CalaveritaForm> {
  var _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final agent = CopilotAgentScope.of(context);
    // The agent only sees non-empty state, so share the empty form first.
    // Waits a frame: setting state while the tree builds would rebuild
    // widgets that are still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (agent.state.sharedState == null) {
        agent.setSharedState(SharedState(const CalaveritaDraft().toJson()));
      }
    });
  }

  static CalaveritaDraft _draftOf(CopilotAgentState state) =>
      state.sharedState?.decode(CalaveritaDraft.fromJson) ??
      const CalaveritaDraft();

  /// Edits one field of the shared state.
  void _edit(String field, String value) {
    CopilotAgentScope.of(context)
        .patchSharedState([StatePatchAdd(path: '/$field', value: value)]);
  }

  @override
  Widget build(BuildContext context) {
    return AgentStateBuilder<CalaveritaDraft>(
      selector: _draftOf,
      builder: (context, draft) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SyncedTextField(
              key: const Key('calaverita_name_field'),
              label: 'Name',
              hint: 'Who is the calaverita for?',
              value: draft.name,
              onChanged: (name) => _edit('name', name),
            ),
            const SizedBox(height: 16),
            _SyncedTextField(
              key: const Key('calaverita_job_field'),
              label: 'Job',
              hint: 'What do they do all day?',
              value: draft.job,
              onChanged: (job) => _edit('job', job),
            ),
            const SizedBox(height: 16),
            SegmentedButton<Tone>(
              key: const Key('calaverita_tone_selector'),
              segments: [
                for (final tone in Tone.values)
                  ButtonSegment(value: tone, label: Text(tone.label)),
              ],
              selected: {draft.tone},
              onSelectionChanged: (selection) =>
                  _edit('tone', selection.first.name),
            ),
            const SizedBox(height: 24),
            BlocBuilder<CalaveritaCubit, CalaveritaState>(
              builder: (context, state) {
                final isGenerating =
                    state.status == GenerationStatus.generating;
                return FilledButton.icon(
                  key: const Key('calaverita_generate_button'),
                  onPressed: draft.isComplete && !isGenerating
                      ? () => context.read<CalaveritaCubit>().generate(draft)
                      : null,
                  icon: isGenerating
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('💀'),
                  label: const Text('Write my calaverita'),
                );
              },
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
/// the state (the keyboard or the agent) shows up in the field.
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
