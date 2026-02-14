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
    for (final (code, _, symbol) in supportedCurrencies) {
      if (code == currency.toUpperCase()) return symbol;
    }
    return currency;
  }

  /// Ordered roughly by global popularity / likely user base.
  static const supportedCurrencies = [
    ('GBP', 'British Pound', '£'),
    ('USD', 'US Dollar', '\$'),
    ('EUR', 'Euro', '€'),
    ('JPY', 'Japanese Yen', '¥'),
    ('CNY', 'Chinese Yuan', '¥'),
    ('INR', 'Indian Rupee', '₹'),
    ('KRW', 'Korean Won', '₩'),
    ('AUD', 'Australian Dollar', 'A\$'),
    ('CAD', 'Canadian Dollar', 'C\$'),
    ('BRL', 'Brazilian Real', 'R\$'),
    ('SEK', 'Swedish Krona', 'kr'),
    ('NOK', 'Norwegian Krone', 'kr'),
    ('DKK', 'Danish Krone', 'kr'),
    ('NZD', 'New Zealand Dollar', 'NZ\$'),
    ('CHF', 'Swiss Franc', 'CHF'),
    ('SGD', 'Singapore Dollar', 'S\$'),
    ('HKD', 'Hong Kong Dollar', 'HK\$'),
    ('MXN', 'Mexican Peso', 'MX\$'),
    ('ZAR', 'South African Rand', 'R'),
    ('THB', 'Thai Baht', '฿'),
    ('PLN', 'Polish Zloty', 'zł'),
    ('TRY', 'Turkish Lira', '₺'),
  ];
}
