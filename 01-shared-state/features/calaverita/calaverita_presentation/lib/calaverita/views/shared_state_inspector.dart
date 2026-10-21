import 'dart:convert';

import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';

/// Shows the shared state as JSON, live: what the agent sees and edits.
class SharedStateInspector extends StatelessWidget {
  const SharedStateInspector({super.key});

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('shared_state_inspector'),
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shared state', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            AgentStateBuilder<SharedState?>(
              selector: (state) => state.sharedState,
              builder: (context, shared) => SelectableText(
                _encoder.convert(shared?.toJson() ?? const <String, Object?>{}),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
