import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Paths of the bundled SVG assets (package `app_ui`).
abstract final class AppAssets {
  /// Package name used to resolve assets.
  static const String package = 'app_ui';

  /// Unicorn mark drawn for navy backgrounds (white body).
  static const String unicorn = 'assets/images/unicorn.svg';

  /// Unicorn mark drawn for light backgrounds (black).
  static const String unicornDark = 'assets/images/unicorn-dark.svg';

  /// Very Good Ventures lockup (black wordmark).
  static const String vgvLockup = 'assets/images/vgv-lockup.svg';

  /// The CopilotKit logo, dark on a transparent-free white background: show it
  /// on a light surface.
  static const String copilotKitLogo = 'assets/images/copilotkit-logo.png';
}

/// The VGV unicorn.
class AppUnicorn extends StatelessWidget {
  /// Creates the unicorn at [size].
  const AppUnicorn({
    required this.size,
    this.onNavy = true,
    this.semanticLabel,
    super.key,
  });

  /// Width and height.
  final double size;

  /// Pick the white variant for navy backgrounds (default) or the black one
  /// for light backgrounds.
  final bool onNavy;

  /// Accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      onNavy ? AppAssets.unicorn : AppAssets.unicornDark,
      package: AppAssets.package,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
    );
  }
}

/// The Very Good Ventures lockup, optionally tinted.
class AppVgvLockup extends StatelessWidget {
  /// Creates the lockup at [height].
  const AppVgvLockup({required this.height, this.color, super.key});

  /// Height; width follows the 2209:765 aspect ratio.
  final double height;

  /// Tint (e.g. white on navy). Null keeps the black artwork.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.vgvLockup,
      package: AppAssets.package,
      height: height,
      semanticsLabel: 'Very Good Ventures',
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// The CopilotKit logo: a dark wordmark on white, so it belongs on a light
/// surface, like a pill on the navy banner.
class AppCopilotKitLogo extends StatelessWidget {
  /// Creates the logo [height] logical pixels tall.
  const AppCopilotKitLogo({required this.height, super.key});

  /// Height of the logo.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.copilotKitLogo,
      package: AppAssets.package,
      height: height,
      semanticLabel: 'CopilotKit',
    );
  }
}
