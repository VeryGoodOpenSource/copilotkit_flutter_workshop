# app_ui

Design system of the **Very Good Coffee Manager** Flutter demo, ported from the
React demo's `styles.css`. Presentational and domain-free: widgets take plain
strings, numbers and enums, and the app maps its own models onto them.

```dart
import 'package:app_ui/app_ui.dart';

MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark, ...);
```

`app_ui.dart` also re-exports `package:flutter/material.dart`.

Run the gallery: `cd example && flutter run -d chrome`.

## Tokens

| Class | Contents |
| --- | --- |
| `AppColors` | Raw brand constants: navy `#0C1A45`, accent `#2A48DE`, ground `#E9EDF8`, stage colors, wash colors, on-navy tints. |
| `AppPalette` | `ThemeExtension` of semantic roles (`ground`, `surface`, `cardGround`, `navy`, `ink`, `inkSecondary`, `inkTertiary`, `heading`, `accent`, `accentWash`, `positive`, `negative`, ...). Light and dark. Read with `context.palette`. |
| `AppSpacing` | `xxs` 2, `xs` 4, `sm` 6, `md` 8, `lg` 10, `xl` 12, `xxl` 14, `x3l` 16, `x4l` 20, `x5l` 24, `x6l` 28, `x7l` 32. |
| `AppRadii` | `card` 28, `dialog` 32, `proposal` 24, `row` 18, `option` 16, `chip` 14, `pill`, plus `BorderRadius` constants. |
| `AppTypography` | Poppins (bundled): `big`, `display`, `headline`, `brand`, `title`, `subtitle`, `bodyLarge`, `body`, `bodyMedium`, `small`, `smallMedium`, `micro`, `chip`, `tag`, `button`, `buttonBig`, `mono` (tabular figures). |
| `AppElevation` | `card`, `dialog`, `segment`, `iconButton` shadows; `scrim`, `brandScrim`, `resultScrim`. |
| `AppMotion` | Durations and the `ease` curve `cubic-bezier(0.2, 0.8, 0.2, 1)`. |
| `AppSizes` | Control heights, icon sizes, dot, bar, avatar, dialog widths. |

`AppTheme.light` / `AppTheme.dark` are Material 3 themes built from these.

## Widgets

- Buttons: `AppButton` (`.primary`, `.ghost`, `size`, `icon`, `onNavy`, `expanded`), `AppIconButton`, `AppSegmented<T>`.
- Labels: `AppChip` (+ `AppTone`), `AppVerdictChip`, `AppSeverityChip`, `AppCountBadge`, `AppStageDot`, `AppStepPill`, `AppGoalChip`.
- Surfaces: `AppCard`, `AppPanel`, `AppSectionHeader`.
- Data: `AppStatTile`, `AppProgressBar`, `AppKeyValueRow`, `AppAvatar`, `AppPersonRow`, `AppSkeleton`, `AppSkeletonBlock`.
- Orders: `AppOrderRow` (`AppUrgency`: normal, warn, urgent, done).
- Chat: `AppChatBubble` (`AppChatRole`: customer, courier, manager), `AppTypingBubble`, `AppComposer`, `AppSuggestionChip`.
- Copilot: `AppDecisionCard`, `AppOptionTile`.
- Overlays: `showAppDialog`, `AppDialogScaffold`, `AppWelcomeDialog`, `AppDialogStep`, `AppResultDialog`, `AppToast`.
- Brand: `AppUnicorn`, `AppVgvLockup`, `AppAssets` (SVGs bundled under `assets/images`).
- Icons: `AppIcons` + `AppIcon` (Material rounded glyphs; see below).

## Notes

- `phosphor_flutter` 2.1.0 (latest) does not compile on Flutter 3.47 (`IconData`
  is a final class), so icons use Material. `AppIcons` is the single seam to swap
  Phosphor back in later.
- Poppins is bundled as a font asset (no network). JetBrains Mono is not
  bundled; `AppTypography.mono` falls back to the platform monospace with
  tabular figures.

## Tests

`flutter test --coverage` (tests live in `test/src`, one file per widget group).
