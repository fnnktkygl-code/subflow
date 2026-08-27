// lib/models/money.dart

import 'package:intl/intl.dart';

class Money {
  final double amount;
  final String currencyCode;
  final String currencySymbol;

  const Money({
    required this.amount,
    this.currencyCode = 'EUR',
    this.currencySymbol = '€',
  });

  factory Money.zero([String currencySymbol = '€']) =>
      Money(amount: 0.0, currencySymbol: currencySymbol);

  factory Money.fromDouble(double val, {String currencySymbol = '€'}) =>
      Money(amount: val, currencySymbol: currencySymbol);

  Money operator +(Money other) =>
      Money(amount: amount + other.amount, currencySymbol: currencySymbol);

  Money operator -(Money other) =>
      Money(amount: amount - other.amount, currencySymbol: currencySymbol);

  Money operator *(double factor) =>
      Money(amount: amount * factor, currencySymbol: currencySymbol);

  Money operator /(double divisor) =>
      Money(amount: amount / divisor, currencySymbol: currencySymbol);

  bool get isPositive => amount > 0;
  bool get isNegative => amount < 0;
  bool get isZero => amount.abs() < 0.001;

  double get absoluteAmount => amount.abs();

  String formatted({bool showSign = false, int decimalDigits = 2}) {
    final format = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
      customPattern: '#,##0.00 \u00A4',
    );
    final absFormatted = format.format(amount.abs());
    if (showSign) {
      if (amount < 0) return '-$absFormatted';
      if (amount > 0) return '+$absFormatted';
    }
    return absFormatted;
  }

  @override
  String toString() => formatted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          (amount - other.amount).abs() < 0.0001 &&
          currencySymbol == other.currencySymbol;

  @override
  int get hashCode => Object.hash((amount * 100).round(), currencySymbol);
}
