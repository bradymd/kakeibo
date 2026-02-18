# Changelog

All notable changes to the Kakeibo app will be documented in this file.

## [1.0.0+11]

### Added
- Backup & Restore in Settings — create a ZIP backup and share/save it, or restore from file
- Automatic daily backup runs silently while the app is open and on cold start
- Auto-backup info card in Settings showing last backup time and size, with one-tap restore
- Tip jar (in-app purchase) on About page — two consumable tips: "A small thank you" and "Buy me a coffee"
- Updated app icon (yen purse design)

### Fixed
- Expenses with the same date now sort newest-first (added createdAt timestamp)
- Support page link in Settings and About page (opens bradymd.github.io/kakeibo)
- PayPal donation card on GitHub support page
- iOS Privacy Manifest for App Store compliance
- Encryption compliance declaration in Info.plist
- Android release signing configuration
- ProGuard/R8 rules for release builds
- Codemagic Android release workflow
- Dart obfuscation for release builds
- Privacy policy page
- Public-facing README

### Changed
- INTERNET permission added to main Android manifest (was only in debug)

## [1.0.0+5]

### Added
- Search utility to find expenses across all months
- Rename categories tool for fixed costs
- Currency dropdown selector (GBP, USD, EUR, JPY, and more)
- Dynamic version display in app settings
- About Kakeibo page with historical context about Hani Motoko
- Directional swipe navigation between dashboard, expenses, and fixed costs

### Changed
- Pillar selector uses Wrap layout instead of GridView to fix excess spacing
- Pillar labels improved with better formatting

## [1.0.0+3]

### Added
- Dedicated Income page with multiple income sources
- Import feature to carry forward fixed costs from previous months
- Edit support for income entries
- Swipe-to-delete with confirmation dialogs

## [1.0.0+2]

### Added
- Codemagic CI/CD pipeline for iOS TestFlight builds

### Changed
- Redesigned Start of Month screen — savings goal is now a text field (removed slider)
- Month navigator centered in header
- Renamed Settings header to "App Settings" to match hamburger menu

### Fixed
- iOS header distortion caused by CherryBlossomDecoration overlay

### Removed
- Cherry blossom image asset
- Savings goal slider (replaced with direct text input)

## [1.0.0+1] - Initial Release

### Added
- Japanese Kakeibo budgeting methodology
- Four Pillars tracking (Needs, Wants, Culture, Unexpected)
- Monthly income and savings goal setup
- Fixed costs management
- Expense tracking with categories
- Budget visualization with progress bars and stacked budget bar
- Monthly reflection with pig/wolf mascot icons
- Hamburger menu navigation with kanji labels
- Day-of-month progress blocks
- Proportional spending bars on Four Pillars cards
- Conditional summary messages based on savings and spending status
- Intelligent narrative summary on Monthly Reflection page
