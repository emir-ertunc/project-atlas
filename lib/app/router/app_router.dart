import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/features/foundation/presentation/foundation_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: FoundationScreen.path,
    routes: [
      GoRoute(
        path: FoundationScreen.path,
        name: FoundationScreen.routeName,
        builder: (context, state) => const FoundationScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
