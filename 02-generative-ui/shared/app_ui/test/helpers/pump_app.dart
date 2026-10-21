import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside an [AppTheme] material app.
  Future<void> pumpApp(
    Widget widget, {
    bool dark = false,
    bool settle = true,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(body: Center(child: widget)),
      ),
    );
    if (settle) {
      await pump(const Duration(milliseconds: 500));
    } else {
      await pump();
    }
  }
}
