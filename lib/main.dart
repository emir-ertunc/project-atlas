import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/app/project_atlas_app.dart';

void main() {
  runApp(const ProviderScope(child: ProjectAtlasApp()));
}
