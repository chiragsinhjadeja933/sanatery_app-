import 'package:intl/intl.dart';

class Formatters {
  // Currency Formatter (Indian Rupee ₹)
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyDecimalFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatCurrency(dynamic amount, {bool showDecimals = false}) {
    if (amount == null) return '₹0';
    double value = 0;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    }
    return showDecimals
        ? _currencyDecimalFormatter.format(value)
        : _currencyFormatter.format(value);
  }

  // Date Formatters
  static String formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      try {
        dt = DateTime.parse(date);
      } catch (_) {
        return date;
      }
    } else {
      return '';
    }
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String formatShortDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      try {
        dt = DateTime.parse(date);
      } catch (_) {
        return date;
      }
    } else {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String formatApiDate(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static String formatMonthYear(int month, int year) {
    final dt = DateTime(year, month, 1);
    return DateFormat('MMMM yyyy').format(dt);
  }

  static String formatOvertime(dynamic otHours) {
    if (otHours == null) return '0 hrs';
    double val = 0;
    if (otHours is num) {
      val = otHours.toDouble();
    } else if (otHours is String) {
      val = double.tryParse(otHours) ?? 0;
    }
    return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} hrs';
  }
}
