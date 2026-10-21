import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_card.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_form.dart';
import 'package:calaverita_presentation/calaverita/views/shared_state_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The form and the finished calaverita, with [trailingPanel] beside them.
class CalaveritaPage extends StatelessWidget {
  const CalaveritaPage({this.trailingPanel, super.key});

  /// A panel shown beside the form, or below it on a narrow screen.
  final Widget? trailingPanel;

  /// Width from which the panel sits beside the form.
  static const _wideBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final panel = trailingPanel;
    return Scaffold(
      appBar: AppBar(title: const Text('💀 Calaverita Generator')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (panel == null) return const _FormColumn();
            if (constraints.maxWidth >= _wideBreakpoint) {
              return Row(
                children: [
                  const Expanded(child: _FormColumn()),
                  const VerticalDivider(width: 1),
                  SizedBox(width: 420, child: panel),
                ],
              );
            }
            return Column(
              children: [
                const Expanded(child: _FormColumn()),
                const Divider(height: 1),
                SizedBox(height: 320, child: panel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormColumn extends StatelessWidget {
  const _FormColumn();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CalaveritaForm(),
            const SizedBox(height: 16),
            const SharedStateInspector(),
            const SizedBox(height: 24),
            BlocBuilder<CalaveritaCubit, CalaveritaState>(
              builder: (context, state) {
                if (state.status == GenerationStatus.failure) {
                  return Text(
                    'The skull lost its voice. Try again.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                final calaverita = state.calaverita;
                if (calaverita == null) return const SizedBox.shrink();
                return CalaveritaCard(calaverita: calaverita);
              },
            ),
          ],
        ),
      ),
    );
  }
}
