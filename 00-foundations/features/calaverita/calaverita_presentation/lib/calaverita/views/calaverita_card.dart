import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:flutter/material.dart';

/// A finished calaverita, ready to read aloud.
class CalaveritaCard extends StatelessWidget {
  const CalaveritaCard({required this.calaverita, super.key});

  final Calaverita calaverita;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💀 Calaverita for ${calaverita.name}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${calaverita.job} · ${calaverita.tone.label}',
              style: theme.textTheme.labelLarge,
            ),
            const Divider(height: 24),
            for (final line in calaverita.lines)
              Text(
                line,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
