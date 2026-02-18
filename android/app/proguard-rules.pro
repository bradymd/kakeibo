# Keep Drift/SQLite native bindings
-keep class io.flutter.plugins.** { *; }

# Keep sqlite3 native library references
-keep class org.sqlite.** { *; }
-keep class sqlite3.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotation classes
-dontwarn javax.annotation.**
