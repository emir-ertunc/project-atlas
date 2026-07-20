import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/performance/performance_markers.dart';

void main() {
  PerformanceMarkers.mark('app_main');
  runApp(const ProviderScope(child: ProjectAtlasApp()));
}
