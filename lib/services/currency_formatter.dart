import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(double amount, {String currency = 'GBP', String locale = 'en_GB'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _currencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String symbol({String currency = 'GBP'}) {
    return _currencySymbol(currency);
  }

  static String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return currency;
    }
  }

  static const supportedCurrencies = [
    ('GBP', 'British Pound', '£'),
    ('USD', 'US Dollar', '\$'),
    ('EUR', 'Euro', '€'),
    ('JPY', 'Japanese Yen', '¥'),
    ('KRW', 'Korean Won', '₩'),
    ('CNY', 'Chinese Yuan', '¥'),
    ('INR', 'Indian Rupee', '₹'),
    ('AUD', 'Australian Dollar', 'A\$'),
    ('CAD', 'Canadian Dollar', 'C\$'),
  ];
}
