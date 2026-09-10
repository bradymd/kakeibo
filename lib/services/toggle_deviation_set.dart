/// Helper for a "select all / deselect all" bulk action over checkboxes
/// whose *individual* default state can vary per item (as on the import
/// screen: items flagged as likely-already-copied default unchecked,
/// everything else defaults checked).
///
/// The screen tracks deviations from each item's own default in a single
/// `Set<String> toggled` (an id is in the set iff the user has flipped that
/// item away from its computed default) rather than a plain "is checked"
/// set, so that re-checking a flagged duplicate is a real, explicit,
/// individually-trackable opt-in. A bulk select-all/deselect-all pass must
/// therefore decide membership by comparing the *target* checked state
/// against each item's *default*, not against its current state -- diffing
/// against current state double-applies to any item a user had already
/// toggled before pressing the bulk control. See the regression tests in
/// toggle_deviation_set_test.dart for the exact failure this replaced.
class ToggleDeviationSet {
  const ToggleDeviationSet._();

  /// Returns the new deviation set after a bulk select-all/deselect-all
  /// action targeting [targetChecked] for every item in [items], where
  /// each item is `(id, defaultChecked)`. [previouslyToggled] is the
  /// deviation set before the bulk action (individual per-item toggles
  /// made before this bulk action are all superseded by it, since a bulk
  /// action targets every item).
  static Set<String> applyBulkTarget({
    required bool targetChecked,
    required List<(String id, bool defaultChecked)> items,
  }) {
    final result = <String>{};
    for (final (id, defaultChecked) in items) {
      if (targetChecked != defaultChecked) result.add(id);
    }
    return result;
  }

  /// Whether every item in [items] (each `(id, defaultChecked)`) is
  /// currently checked, given [toggled] -- used to decide whether the
  /// bulk control's label should read "Select all" or "Deselect all", and
  /// what its target state should be if pressed.
  static bool allChecked({
    required Set<String> toggled,
    required List<(String id, bool defaultChecked)> items,
  }) {
    return items.every((i) => isChecked(id: i.$1, defaultChecked: i.$2, toggled: toggled));
  }

  /// Whether a single item is currently checked: its default, XOR whether
  /// the user has explicitly toggled it away from that default.
  static bool isChecked({
    required String id,
    required bool defaultChecked,
    required Set<String> toggled,
  }) {
    return toggled.contains(id) ? !defaultChecked : defaultChecked;
  }
}
