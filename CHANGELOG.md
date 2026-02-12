# Changelog

All notable changes to the Kakeibo app will be documented in this file.

## [Unreleased]

### Added
- Income and Fixed Costs breakdown now displayed at top of main page
- Conditional summary messages based on savings goal and spending status
- Better handling of £0 and negative amounts in budget bar labels
- Intelligent narrative summary on Monthly Reflection page that adapts based on:
  - Income and fixed costs breakdown
  - Whether a savings goal was set
  - Spending outcome (met goal, partial savings, or overspent)
- Japanese-style pig and wolf mascot icons on Monthly Reflection:
  - Pig icon (貯試) appears when savings goals are met
  - Wolf icon (設出) appears when savings goals are not met or overspent

### Changed
- Fixed Costs now displayed in red for better visibility
- Renamed "Fixed Expense" to "Fixed Cost" throughout the app
- Reordered Fixed Costs form: Category → Amount → Name (optional)
- Name field is now optional when adding Fixed Costs
- Summary messages now contextual:
  - With savings goal: "To meet your savings goal of £X, you have £Y remaining"
  - Without savings goal: "You have £X left to spend or save"
  - When overspent: "You are overspent by £X"

### Fixed
- Form validation now works immediately as you type (Add Expense, Fixed Costs, Income)
- Button enable/disable state updates in real-time without needing to click other fields
- Removed prescriptive "ideal budget" display from Four Pillars - now shows only actual spending
- Floating action button displays tooltip on hover

## [1.0.0+1] - Initial Release

### Added
- Japanese Kakeibo budgeting methodology
- Four Pillars tracking (Needs, Wants, Culture, Unexpected)
- Monthly income and savings goal setup
- Fixed costs management
- Expense tracking with categories
- Budget visualization with progress bars
- Monthly reflection feature
