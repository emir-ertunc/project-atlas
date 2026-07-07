import 'package:flutter/material.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  static const path = '/';
  static const routeName = 'foundation';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, size: 64),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.foundationSetupComplete),
            ],
          ),
        ),
      ),
    );
  }
}
