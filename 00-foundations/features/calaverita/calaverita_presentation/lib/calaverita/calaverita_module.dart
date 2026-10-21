import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// The calaverita screen with everything it needs.
class CalaveritaModule extends StatelessWidget {
  const CalaveritaModule({required this.calaveritasRepository, super.key});

  final ICalaveritasRepository calaveritasRepository;

  @override
  Widget build(BuildContext context) {
    return Provider<ICalaveritasRepository>.value(
      value: calaveritasRepository,
      child: BlocProvider(
        create: (context) =>
            CalaveritaCubit(calaveritasRepository: context.read()),
        child: const CalaveritaPage(),
      ),
    );
  }
}
