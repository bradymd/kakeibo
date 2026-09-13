import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Regression test for the disabled ToyPrimaryButton appearance, reported
/// live on both Android and iOS as "the shadow being lighter and above
/// the button" on Save Expense/Add Expense/Fixed Cost/Save Income --
/// every screen whose ToyPrimaryButton has an enable/disable gate.
/// (Complete Reflection's button has no gate at all, so it never showed
/// the problem.)
///
/// Root cause: the previous disabled styling alpha-blended both the fill
/// (0.5) and shadow (0.4) colours independently, straight over whatever
/// screen background sat behind the button -- so the apparent face/
/// shadow relationship varied with the background and compressed badly
/// (measured: a 47-unit luminance gap enabled shrank to 15.4 disabled).
///
/// Fixed per Codex's review: disabled is now flat and background-
/// independent -- opaque ToyColors.goldBg2 face, no shadow at all,
/// ToyColors.muted label -- rather than a dimmer version of the raised
/// enabled look.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  // ToyPressable's AnimatedContainer also builds an implicit Container
  // internally, so a plain find.byType(Container) under it matches two
  // widgets -- the outer implicit one (decoration: null) and the actual
  // decorated Container this button builds. Find the decorated one
  // specifically rather than assuming ordering.
  BoxDecoration findButtonDecoration(WidgetTester tester) {
    final containers = tester
        .widgetList<Container>(
          find.descendant(of: find.byType(ToyPressable), matching: find.byType(Container)),
        )
        .where((c) => c.decoration != null);
    return containers.single.decoration as BoxDecoration;
  }

  group('ToyPrimaryButton disabled/enabled styling', () {
    testWidgets('disabled: opaque goldBg2 face, muted text, no shadow, no tap',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ToyPrimaryButton(label: 'Save income', onTap: null)),
      );

      final decoration = findButtonDecoration(tester);

      expect(decoration.color, ToyColors.goldBg2,
          reason: 'disabled face must be the flat, opaque goldBg2 token, not '
              'a translucent version of the enabled gold');
      expect(decoration.boxShadow, anyOf(isNull, isEmpty),
          reason: 'disabled must have no shadow at all -- it should not '
              'retain any raised/pressable affordance');

      final text = tester.widget<Text>(find.text('Save income'));
      expect(text.style?.color, ToyColors.muted,
          reason: 'disabled label must use the flat muted ink token');

      final pressable = tester.widget<ToyPressable>(find.byType(ToyPressable));
      expect(pressable.onTap, isNull,
          reason: 'a disabled button must not forward a live tap callback');
    });

    testWidgets('enabled: gold face, goldShadow with a positive downward '
        'offset, live callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(ToyPrimaryButton(label: 'Save income', onTap: () => tapped = true)),
      );

      final decoration = findButtonDecoration(tester);

      expect(decoration.color, ToyColors.gold);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow, isNotEmpty);
      final shadow = decoration.boxShadow!.single;
      expect(shadow.color, ToyColors.goldShadow);
      expect(shadow.offset.dy, greaterThan(0),
          reason: 'the shadow must sit BELOW the face (a positive downward '
              'offset), not above it');

      final text = tester.widget<Text>(find.text('Save income'));
      expect(text.style?.color, ToyColors.goldInk);

      final pressable = tester.widget<ToyPressable>(find.byType(ToyPressable));
      expect(pressable.onTap, isNotNull);
      await tester.tap(find.byType(ToyPrimaryButton));
      expect(tapped, isTrue);
    });

    testWidgets(
        'a parent going from invalid to valid rebuilds the same button '
        'from the disabled palette straight into the enabled one',
        (tester) async {
      // Mirrors the real screens: onTap is null while _canSave is false,
      // then becomes a live callback once the parent's state changes --
      // this is exactly the transition the app owner described as "now
      // actionable" once the form was filled in correctly.
      await tester.pumpWidget(
        wrap(const ToyPrimaryButton(label: 'Save income', onTap: null)),
      );
      expect(findButtonDecoration(tester).color, ToyColors.goldBg2);

      await tester.pumpWidget(
        wrap(ToyPrimaryButton(label: 'Save income', onTap: () {})),
      );
      await tester.pump();

      final decoration = findButtonDecoration(tester);
      expect(decoration.color, ToyColors.gold,
          reason: 'the button must switch to the enabled palette once a '
              'live onTap is supplied, not stay stuck on the disabled one');
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow, isNotEmpty);
    });
  });
}
