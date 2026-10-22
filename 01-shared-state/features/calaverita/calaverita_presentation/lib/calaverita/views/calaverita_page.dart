import 'package:app_ui/app_ui.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/draft_edits.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/shared_draft.dart';
import 'package:calaverita_presentation/calaverita/views/details_panel.dart';
import 'package:calaverita_presentation/calaverita/views/stage.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Width at or above which the columns are side by side.
const _desktopBreakpoint = 1000.0;

/// The one screen: the details on the left and the stage in the middle,
/// with [trailingPanel] on the right.
///
/// The details and the stage read the form from the agent's shared state, so
/// the page needs a `CopilotAgentScope` above it.
class CalaveritaPage extends StatefulWidget {
  const CalaveritaPage({this.trailingPanel, super.key});

  /// A panel the app puts beside the stage, or below it on a narrow screen.
  final Widget? trailingPanel;

  @override
  State<CalaveritaPage> createState() => _CalaveritaPageState();
}

class _CalaveritaPageState extends State<CalaveritaPage> {
  @override
  void initState() {
    super.initState();
    // Waits a frame: sharing state while the tree builds would rebuild
    // widgets that are still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) DraftEdits.of(context).ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.ground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4l,
                AppSpacing.x3l,
                AppSpacing.x4l,
                AppSpacing.x4l,
              ),
              child: Column(
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.x3l),
                  Expanded(child: _Layout(trailingPanel: widget.trailingPanel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [p.navy, p.navyAlt]),
        borderRadius: AppRadii.cardBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5l,
          vertical: AppSpacing.xl,
        ),
        child: Row(
          spacing: AppSpacing.x5l,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calaverita Generator',
                    style: AppTypography.title.copyWith(color: p.onNavy),
                  ),
                  Text(
                    'A funny rhyming skull for someone you love.',
                    style: AppTypography.small.copyWith(color: p.onNavyMuted),
                  ),
                ],
              ),
            ),
            const _Logos(),
          ],
        ),
      ),
    );
  }
}

class _Layout extends StatelessWidget {
  const _Layout({this.trailingPanel});

  final Widget? trailingPanel;

  @override
  Widget build(BuildContext context) {
    final panel = trailingPanel;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3l,
            children: [
              const SizedBox(width: 380, child: _Details()),
              const Expanded(child: _Stage()),
              if (panel != null) SizedBox(width: 420, child: panel),
            ],
          );
        }
        return SingleChildScrollView(
          child: Column(
            spacing: AppSpacing.x3l,
            children: [
              const SizedBox(height: 640, child: _Stage()),
              if (panel != null) SizedBox(height: 520, child: panel),
              const SizedBox(height: 760, child: _Details()),
            ],
          ),
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalaveritaCubit>();
    final edits = DraftEdits.of(context);
    return SharedDraft(
      builder: (context, draft) =>
          BlocBuilder<CalaveritaCubit, CalaveritaState>(
            builder: (context, state) {
              final isGenerating = state.status == GenerationStatus.generating;
              return DetailsPanel(
                draft: draft,
                canGenerate: draft.isComplete && !isGenerating,
                isGenerating: isGenerating,
                onNameChanged: edits.nameChanged,
                onJobChanged: edits.jobChanged,
                onToneChanged: edits.toneChanged,
                onSkullPartChanged: edits.skullPartChanged,
                onSkullColorChanged: edits.skullColorChanged,
                onGenerate: () => cubit.generate(draft),
              );
            },
          ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return SharedDraft(
      builder: (context, draft) =>
          BlocBuilder<CalaveritaCubit, CalaveritaState>(
            builder: (context, state) => Stage(
              skull: draft.skull,
              status: state.status,
              calaverita: state.calaverita,
              badge: const _AgentBadge(),
            ),
          ),
    );
  }
}

/// "Copilot is working…" while the agent handles a request.
class _AgentBadge extends StatelessWidget {
  const _AgentBadge();

  @override
  Widget build(BuildContext context) {
    return AgentStateBuilder<bool>(
      selector: (state) => state.isRunning,
      builder: (context, busy) => AnimatedOpacity(
        duration: AppMotion.quick,
        opacity: busy ? 1 : 0,
        child: const AppChip(
          label: 'Copilot is working…',
          icon: AppIcons.sparkle,
          tone: AppTone.accent,
        ),
      ),
    );
  }
}

/// The CopilotKit and VGV logos on the right of the banner. They make way for
/// the title on a narrow screen.
class _Logos extends StatelessWidget {
  const _Logos();

  /// Width of the screen from which the logos are shown.
  static const _minWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < _minWidth) {
      return const SizedBox.shrink();
    }
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.x4l,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.pillBorder,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: AppCopilotKitLogo(height: 26),
          ),
        ),
        AppVgvLockup(height: 28, color: p.onNavy),
      ],
    );
  }
}
