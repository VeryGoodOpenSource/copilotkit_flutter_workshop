import 'package:calaverita_app/app/app.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App(skullArt: await SkullArt.load()));
}
