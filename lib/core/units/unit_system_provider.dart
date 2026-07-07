import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/units/measurement_units.dart';

final unitSystemProvider = Provider<UnitSystem>((ref) => UnitSystem.metric);
