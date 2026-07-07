import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/units/measurement_units.dart';
import 'package:project_atlas/core/units/unit_formatter.dart';
import 'package:project_atlas/core/units/unit_system_provider.dart';

void main() {
  group('Mass', () {
    test('converts kilograms and pounds using the exact factor', () {
      const mass = Mass.kilograms(100);
      final roundTrip = Mass.pounds(mass.pounds);

      expect(mass.pounds, closeTo(220.462262, 0.000001));
      expect(roundTrip.kilograms, closeTo(100, 0.000000001));
    });

    test('rejects negative values', () {
      expect(() => Mass.kilograms(-1), throwsA(isA<AssertionError>()));
    });
  });

  group('Length', () {
    test('converts centimeters and inches using the exact factor', () {
      const length = Length.centimeters(2.54);
      final roundTrip = Length.inches(length.inches);

      expect(length.inches, closeTo(1, 0.000000001));
      expect(roundTrip.centimeters, closeTo(2.54, 0.000000001));
    });

    test('rejects negative values', () {
      expect(() => Length.centimeters(-1), throwsA(isA<AssertionError>()));
    });
  });

  group('UnitFormatter', () {
    test('uses metric units and Turkish decimal separators', () {
      const formatter = UnitFormatter(
        locale: Locale('tr'),
        unitSystem: UnitSystem.metric,
      );

      expect(formatter.formatMass(const Mass.kilograms(80.5)), '80,5 kg');
      expect(
        formatter.formatLength(const Length.centimeters(180.5)),
        '180,5 cm',
      );
    });

    test('uses imperial units and English decimal separators', () {
      const formatter = UnitFormatter(
        locale: Locale('en'),
        unitSystem: UnitSystem.imperial,
      );

      expect(formatter.formatMass(const Mass.kilograms(100)), '220.5 lb');
      expect(formatter.formatLength(const Length.centimeters(180)), '70.9 in');
    });
  });

  test('unit system provider defaults to metric and supports overrides', () {
    final defaultContainer = ProviderContainer();
    final imperialContainer = ProviderContainer(
      overrides: [unitSystemProvider.overrideWithValue(UnitSystem.imperial)],
    );
    addTearDown(defaultContainer.dispose);
    addTearDown(imperialContainer.dispose);

    expect(defaultContainer.read(unitSystemProvider), UnitSystem.metric);
    expect(imperialContainer.read(unitSystemProvider), UnitSystem.imperial);
  });
}
