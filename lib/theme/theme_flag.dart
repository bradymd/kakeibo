/// Switch between the original theme and the "gachapon" toy-machine
/// redesign. See `design_handoff_gachapon_redesign/ROLLBACK_AND_DATA.md`
/// (not part of the app bundle) for the full rationale.
///
/// This flag only ever needs to gate presentation — colours, type,
/// radii, shadows. Structural screen changes (new tab bar, amount-first
/// Add Expense, etc.) are separate widget trees selected by the router,
/// not by this flag.
const bool kToyTheme = true; // flip to false to ship the old look
