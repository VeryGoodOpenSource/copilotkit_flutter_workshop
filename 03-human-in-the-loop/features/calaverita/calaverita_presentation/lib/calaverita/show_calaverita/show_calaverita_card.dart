import 'dart:convert';

import 'package:app_ui/app_ui.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_args.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_card.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// The generative UI of a `showCalaverita` call: a card in the chat.
///
/// While the agent is still writing it shows a placeholder, and once the
/// call is done the finished [CalaveritaCard].
class ShowCalaveritaCard extends StatelessWidget {
  const ShowCalaveritaCard({required this.call, this.args, super.key});

  /// The call to show.
  final ToolCallView call;

  /// The arguments of [call], or `null` while they can't be decoded yet.
  final ShowCalaveritaArgs? args;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return switch (call.status) {
      ToolCallStatus.inProgress || ToolCallStatus.executing => AppChip(
        label: 'Writing the calaverita…',
        icon: AppIcons.sparkle,
        foreground: p.onNavyMuted,
        background: p.onNavyFill,
      ),
      ToolCallStatus.complete => _finished(context, call.result),
    };
  }

  Widget _finished(BuildContext context, String? result) {
    final calaverita = _calaveritaFrom(result);
    if (calaverita != null) return CalaveritaCard(calaverita: calaverita);
    return Text(
      result ?? '',
      style: AppTypography.small.copyWith(color: context.palette.onNavyMuted),
    );
  }

  /// Decodes the JSON-encoded calaverita in [result], or returns `null` when
  /// it isn't one, e.g. a message saying the form is incomplete.
  Calaverita? _calaveritaFrom(String? result) {
    if (result == null) return null;
    try {
      return switch (jsonDecode(result)) {
        final Map<String, Object?> json => Calaverita.fromJson(json),
        _ => null,
      };
    } on FormatException {
      return null;
    }
  }
}
