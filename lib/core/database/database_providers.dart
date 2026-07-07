import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();

  ref.onDispose(() {
    unawaited(database.close());
  });

  return database;
});
