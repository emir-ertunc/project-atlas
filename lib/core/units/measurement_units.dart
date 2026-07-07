enum UnitSystem {
  metric,
  imperial;

  MassUnit get massUnit => switch (this) {
    UnitSystem.metric => MassUnit.kilogram,
    UnitSystem.imperial => MassUnit.pound,
  };

  LengthUnit get lengthUnit => switch (this) {
    UnitSystem.metric => LengthUnit.centimeter,
    UnitSystem.imperial => LengthUnit.inch,
  };
}

enum MassUnit {
  kilogram('kg'),
  pound('lb');

  const MassUnit(this.symbol);

  final String symbol;
}

enum LengthUnit {
  centimeter('cm'),
  inch('in');

  const LengthUnit(this.symbol);

  final String symbol;
}

final class Mass {
  const Mass.kilograms(this.kilograms)
    : assert(kilograms >= 0, 'Mass cannot be negative.');

  Mass.pounds(double pounds) : this.kilograms(pounds * kilogramsPerPound);

  static const kilogramsPerPound = 0.45359237;

  final double kilograms;

  double get pounds => kilograms / kilogramsPerPound;

  double inUnit(MassUnit unit) => switch (unit) {
    MassUnit.kilogram => kilograms,
    MassUnit.pound => pounds,
  };
}

final class Length {
  const Length.centimeters(this.centimeters)
    : assert(centimeters >= 0, 'Length cannot be negative.');

  Length.inches(double inches) : this.centimeters(inches * centimetersPerInch);

  static const centimetersPerInch = 2.54;

  final double centimeters;

  double get inches => centimeters / centimetersPerInch;

  double inUnit(LengthUnit unit) => switch (unit) {
    LengthUnit.centimeter => centimeters,
    LengthUnit.inch => inches,
  };
}
