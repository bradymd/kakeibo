import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/services/toggle_deviation_set.dart';

/// Regression tests for the bulk select-all/deselect-all bug Codex caught
/// in review: the original inline logic compared each item's *current*
/// checked state to the bulk target, which double-applies when an item was
/// already individually toggled before the bulk action -- e.g. a
/// user-checked duplicate stayed checked instead of following "Deselect
/// all". Correct behaviour compares each item's *default* to the target.
void main() {
  group('ToggleDeviationSet', () {
    test('mixed defaults -> Select all -> every item checked', () {
      // b defaults unchecked (a flagged duplicate); a and c default checked.
      final items = [('a', true), ('b', false), ('c', true)];
      final toggled = ToggleDeviationSet.applyBulkTarget(
        targetChecked: true,
        items: items,
      );
      for (final (id, defaultChecked) in items) {
        expect(
          ToggleDeviationSet.isChecked(id: id, defaultChecked: defaultChecked, toggled: toggled),
          isTrue,
          reason: '$id should be checked after Select all',
        );
      }
    });

    test('all checked (including an opted-in duplicate) -> Deselect all -> none', () {
      final items = [('a', true), ('b', false), ('c', true)];
      // Simulate: b (a duplicate) was manually checked by the user first.
      final toggled = {'b'};
      expect(
        ToggleDeviationSet.isChecked(id: 'b', defaultChecked: false, toggled: toggled),
        isTrue,
        reason: 'sanity check: b should read as checked before the bulk action',
      );

      final afterDeselectAll = ToggleDeviationSet.applyBulkTarget(
        targetChecked: false,
        items: items,
      );
      for (final (id, defaultChecked) in items) {
        expect(
          ToggleDeviationSet.isChecked(
            id: id,
            defaultChecked: defaultChecked,
            toggled: afterDeselectAll,
          ),
          isFalse,
          reason: '$id should be unchecked after Deselect all, including the opted-in duplicate',
        );
      }
    });

    test('manually uncheck a normal row -> Select all -> it is checked again', () {
      final items = [('a', true), ('b', false)];
      // Simulate: a (defaults checked) was manually unchecked first.
      final toggled = {'a'};
      expect(
        ToggleDeviationSet.isChecked(id: 'a', defaultChecked: true, toggled: toggled),
        isFalse,
        reason: 'sanity check: a should read as unchecked before the bulk action',
      );

      final afterSelectAll = ToggleDeviationSet.applyBulkTarget(
        targetChecked: true,
        items: items,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'a', defaultChecked: true, toggled: afterSelectAll),
        isTrue,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'b', defaultChecked: false, toggled: afterSelectAll),
        isTrue,
      );
    });

    test('manually check a duplicate -> Deselect all -> it is unchecked again', () {
      final items = [('a', true), ('b', false)];
      // Sanity check the starting scenario: b (a duplicate) manually
      // checked by the user before the bulk action runs.
      expect(
        ToggleDeviationSet.isChecked(id: 'b', defaultChecked: false, toggled: {'b'}),
        isTrue,
      );

      final afterDeselectAll = ToggleDeviationSet.applyBulkTarget(
        targetChecked: false,
        items: items,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'b', defaultChecked: false, toggled: afterDeselectAll),
        isFalse,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'a', defaultChecked: true, toggled: afterDeselectAll),
        isFalse,
      );
    });

    test('allChecked reports false while any item deviates below target', () {
      final items = [('a', true), ('b', false)];
      expect(ToggleDeviationSet.allChecked(toggled: {}, items: items), isFalse); // b defaults off
      expect(ToggleDeviationSet.allChecked(toggled: {'b'}, items: items), isTrue); // b opted in
    });

    test('a plain per-item toggle (not bulk) still works via isChecked', () {
      // Exercises the everyday single-row tap path, not just the bulk one.
      expect(
        ToggleDeviationSet.isChecked(id: 'x', defaultChecked: true, toggled: {}),
        isTrue,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'x', defaultChecked: true, toggled: {'x'}),
        isFalse,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'x', defaultChecked: false, toggled: {}),
        isFalse,
      );
      expect(
        ToggleDeviationSet.isChecked(id: 'x', defaultChecked: false, toggled: {'x'}),
        isTrue,
      );
    });
  });
}
