import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase.defaults() : super(driftDatabase(name: 'project_atlas'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
