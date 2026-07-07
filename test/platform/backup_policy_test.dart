import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const backupDomains = <String>{
    'root',
    'file',
    'database',
    'sharedpref',
    'external',
    'device_root',
    'device_file',
    'device_database',
    'device_sharedpref',
  };

  test('Android disables backup and declares both rule formats', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('Android excludes every private storage domain from backup', () {
    final legacyRules = File(
      'android/app/src/main/res/xml/backup_rules.xml',
    ).readAsStringSync();
    final modernRules = File(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ).readAsStringSync();

    expect(legacyRules, isNot(contains('<include')));
    expect(modernRules, isNot(contains('<include')));
    expect(modernRules, contains('<cloud-backup>'));
    expect(modernRules, contains('<device-transfer>'));

    for (final domain in backupDomains) {
      final exclusion = RegExp('<exclude domain="$domain" path="\\."\\s*/>');
      expect(exclusion.allMatches(legacyRules), hasLength(1), reason: domain);
      expect(exclusion.allMatches(modernRules), hasLength(2), reason: domain);
    }
  });

  test('iOS excludes the local database directory from device backup', () {
    final appDelegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();

    expect(appDelegate, contains('excludeLocalDataFromBackup()'));
    expect(appDelegate, contains('for: .documentDirectory'));
    expect(appDelegate, contains('isExcludedFromBackup = true'));
  });
}
