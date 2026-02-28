// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      currency: json['currency'] as String? ?? 'GBP',
      locale: json['locale'] as String? ?? 'en-GB',
      paydayPreset: json['paydayPreset'] as String? ?? 'none',
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'locale': instance.locale,
      'paydayPreset': instance.paydayPreset,
    };
