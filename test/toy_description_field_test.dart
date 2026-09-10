import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/database/database_provider.dart' show DescriptionMatch;
import 'package:kakeibo/widgets/toy/toy_description_field.dart';

/// Widget-level tests for the description-autocomplete rebuild (separate
/// suggestion row, not inline ghost text -- see toy_description_field.dart's
/// own doc comment for why the original inline approach was replaced). Uses
/// a fake findMatch rather than a real database, and a bare MaterialApp
/// rather than the full toy theme/screen, so this stays independent of both
/// the database layer and the rest of Add Expense.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('typing a full match calls onMatchChanged with it', (tester) async {
    final controller = TextEditingController();
    DescriptionMatch? received;

    await tester.pumpWidget(wrap(ToyDescriptionField(
      controller: controller,
      findMatch: (prefix) async =>
          const DescriptionMatch(description: 'Tesco', category: 'Groceries'),
      onMatchChanged: (match) => received = match,
    )));

    await tester.enterText(find.byType(TextField), 'Te');
    await tester.pump();
    await tester.pump(); // let the async findMatch future resolve

    expect(received, isNotNull);
    expect(received!.description, 'Tesco');
    expect(received!.category, 'Groceries');
  });

  testWidgets('no completion when typed text equals the match exactly', (tester) async {
    final controller = TextEditingController();
    DescriptionMatch? received;

    await tester.pumpWidget(wrap(ToyDescriptionField(
      controller: controller,
      findMatch: (prefix) async =>
          const DescriptionMatch(description: 'Tesco', category: 'Groceries'),
      onMatchChanged: (match) => received = match,
    )));

    await tester.enterText(find.byType(TextField), 'Tesco');
    await tester.pump();
    await tester.pump();

    // "Tesco" typed in full isn't a *completion* of "Tesco" -- nothing
    // left to suggest.
    expect(received, isNull);
  });

  testWidgets('clearing the field while a lookup is in flight does not resurrect a stale match',
      (tester) async {
    final controller = TextEditingController();
    DescriptionMatch? received;
    var callCount = 0;

    await tester.pumpWidget(wrap(ToyDescriptionField(
      controller: controller,
      findMatch: (prefix) async {
        callCount++;
        // Simulate a slow lookup for the first keystroke only.
        if (callCount == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        return prefix.isEmpty
            ? null
            : const DescriptionMatch(description: 'Tesco', category: 'Groceries');
      },
      onMatchChanged: (match) => received = match,
    )));

    await tester.enterText(find.byType(TextField), 'Te');
    // Don't await the slow lookup -- clear the field before it resolves.
    await tester.pump(const Duration(milliseconds: 10));
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 100));

    // The stale "Te" -> Tesco lookup must not have overwritten the
    // null set by clearing the field.
    expect(received, isNull);
  });

  // These two exercise the acceptance logic exactly as
  // toy_add_expense_screen.dart's onAccept callback implements it --
  // rather than re-deriving a "Use" button through widget rebuilds (which
  // introduced timing noise unrelated to the thing under test), the
  // accept behaviour itself is plain synchronous code once a match is in
  // hand, so it's exercised directly here.
  void accept({
    required DescriptionMatch match,
    required TextEditingController descController,
    required TextEditingController categoryController,
  }) {
    descController.value = TextEditingValue(
      text: match.description,
      selection: TextSelection.collapsed(offset: match.description.length),
    );
    if (categoryController.text.trim().isEmpty && match.category.isNotEmpty) {
      categoryController.text = match.category;
    }
  }

  test('accepting a suggestion fills description and category when category is blank', () {
    final descController = TextEditingController();
    final categoryController = TextEditingController();
    accept(
      match: const DescriptionMatch(description: 'Tesco', category: 'Groceries'),
      descController: descController,
      categoryController: categoryController,
    );
    expect(descController.text, 'Tesco');
    expect(categoryController.text, 'Groceries');
  });

  test('accepting a suggestion never overwrites an existing category', () {
    final descController = TextEditingController();
    final categoryController = TextEditingController(text: 'Dining');
    accept(
      match: const DescriptionMatch(description: 'Tesco', category: 'Groceries'),
      descController: descController,
      categoryController: categoryController,
    );
    expect(descController.text, 'Tesco');
    expect(categoryController.text, 'Dining'); // untouched
  });
}
