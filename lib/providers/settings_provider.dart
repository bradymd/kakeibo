import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/models/user_settings.dart';
import 'package:kakeibo/providers/database_provider.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final db = ref.watch(databaseProvider);
    final currency = await db.getSetting('currency') ?? 'GBP';
    final locale = await db.getSetting('locale') ?? 'en_GB';
    return UserSettings(currency: currency, locale: locale);
  }

  Future<void> setCurrency(String currency) async {
    final db = ref.read(databaseProvider);
    await db.setSetting('currency', currency);
    state = AsyncData(state.requireValue.copyWith(currency: currency));
  }

  Future<void> setLocale(String locale) async {
    final db = ref.read(databaseProvider);
    await db.setSetting('locale', locale);
    state = AsyncData(state.requireValue.copyWith(locale: locale));
  }
}
