import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_card.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The form on top, the finished calaverita below.
class CalaveritaPage extends StatelessWidget {
  const CalaveritaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💀 Calaverita Generator')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CalaveritaForm(),
                const SizedBox(height: 24),
                BlocBuilder<CalaveritaCubit, CalaveritaState>(
                  buildWhen: (previous, current) =>
                      previous.calaverita != current.calaverita ||
                      previous.status != current.status,
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
        ),
      ),
    );
  }
}
