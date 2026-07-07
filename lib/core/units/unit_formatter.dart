import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_atlas/core/units/measurement_units.dart';

final class UnitFormatter {
  const UnitFormatter({required this.locale, required this.unitSystem});

  final Locale locale;
  final UnitSystem unitSystem;

  String formatMass(Mass mass, {int fractionDigits = 1}) {
    final unit = unitSystem.massUnit;
    return '${_format(mass.inUnit(unit), fractionDigits)} ${unit.symbol}';
  }

  String formatLength(Length length, {int fractionDigits = 1}) {
    final unit = unitSystem.lengthUnit;
    return '${_format(length.inUnit(unit), fractionDigits)} ${unit.symbol}';
  }

  String _format(double value, int fractionDigits) {
    final format = NumberFormat.decimalPatternDigits(
      locale: locale.toLanguageTag(),
      decimalDigits: fractionDigits,
    );
    return format.format(value);
  }
}
