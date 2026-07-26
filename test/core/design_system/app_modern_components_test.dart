import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/app_dense_form.dart';
import 'package:project_atlas/core/design_system/components/app_progress_ring.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';

void main() {
  group('modern design system components', () {
    testWidgets('dashboard card is compact, tappable, and high signal', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        _TestHost(
          child: AppDashboardCard(
            title: 'Today',
            subtitle: 'Upper body session',
            leadingIcon: Icons.fitness_center,
            metric: '42 min',
            trend: '+2 streak',
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Upper body session'), findsOneWidget);
      expect(find.text('42 min'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppDashboardCard)),
        hasMinHeight(AppComponentTokens.dashboardCardMinHeight),
      );

      await tester.tap(find.byType(AppDashboardCard));
      expect(taps, 1);
    });

    testWidgets('status chip uses compact display and accessible tap target', (
      tester,
    ) async {
      var taps = 0;
      const reviewChipKey = Key('review-chip');

      await tester.pumpWidget(
        _TestHost(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppStatusChip(
                label: 'On track',
                tone: AppStatusTone.success,
              ),
              AppStatusChip(
                key: reviewChipKey,
                label: 'Review',
                tone: AppStatusTone.warning,
                icon: Icons.warning_amber,
                onTap: () => taps++,
              ),
            ],
          ),
        ),
      );

      expect(find.text('On track'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(reviewChipKey)),
        hasMinHeight(AppComponentTokens.minimumTouchTarget),
      );

      await tester.tap(find.text('Review'));
      expect(taps, 1);
    });

    testWidgets('progress ring clamps progress and exposes semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          const _TestHost(
            child: AppProgressRing(
              progress: 1.4,
              animate: false,
              center: Text('100'),
            ),
          ),
        );

        expect(find.text('100'), findsOneWidget);

        final semanticsNode = tester.getSemantics(find.byType(AppProgressRing));
        expect(semanticsNode.label, '100% complete');
        expect(semanticsNode.value, '100%');
        expect(
          tester.getSize(find.byType(AppProgressRing)),
          const Size.square(AppComponentTokens.standardProgressRingSize),
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('dense form section keeps fields compact but touch-safe', (
      tester,
    ) async {
      await tester.pumpWidget(
        const _TestHost(
          child: AppDenseFormSection(
            title: 'Measurements',
            subtitle: 'Two quick fields',
            children: [
              AppDenseTextField(label: 'Weight', suffixText: 'kg'),
              AppDenseTextField(label: 'Waist', suffixText: 'cm'),
            ],
          ),
        ),
      );

      expect(find.text('Measurements'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      final firstField = tester.widget<TextField>(find.byType(TextField).first);
      final decoration = firstField.decoration;

      expect(decoration?.isDense, isTrue);
      expect(
        decoration?.constraints?.minHeight,
        AppComponentTokens.denseControlHeight,
      );
      expect(decoration?.contentPadding, isA<EdgeInsets>());
    });
  });
}

Matcher hasMinHeight(double minHeight) {
  return predicate<Size>(
    (size) => size.height >= minHeight,
    'has height >= $minHeight',
  );
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
