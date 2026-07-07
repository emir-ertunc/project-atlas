import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('opens an in-memory database and executes a query', () async {
    final row = await database.customSelect('SELECT 1 AS value').getSingle();

    expect(row.read<int>('value'), 1);
    expect(database.schemaVersion, 1);
  });

  test('supports a provider override for isolated tests', () {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    expect(container.read(appDatabaseProvider), same(database));
  });
}
