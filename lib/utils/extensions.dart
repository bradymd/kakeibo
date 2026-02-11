extension DoubleExt on double {
  String toPercentString() {
    return '${(this * 100).toStringAsFixed(0)}%';
  }
}

extension StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
