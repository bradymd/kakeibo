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
    final paydayPreset = await db.getSetting('paydayPreset') ?? 'none';
    return UserSettings(currency: currency, locale: locale, paydayPreset: paydayPreset);
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

  Future<void> setPaydayPreset(String preset) async {
    final db = ref.read(databaseProvider);
    await db.setSetting('paydayPreset', preset);
    state = AsyncData(state.requireValue.copyWith(paydayPreset: preset));
  }

  Future<void> setPaydayOverride(String monthId, String? isoDate) async {
    final db = ref.read(databaseProvider);
    final key = 'paydayOverride_$monthId';
    if (isoDate != null) {
      await db.setSetting(key, isoDate);
    } else {
      await db.deleteSetting(key);
    }
  }

  Future<String?> getPaydayOverride(String monthId) async {
    final db = ref.read(databaseProvider);
    return db.getSetting('paydayOverride_$monthId');
  }
}
