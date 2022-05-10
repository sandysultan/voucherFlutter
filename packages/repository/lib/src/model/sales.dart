import 'package:json_annotation/json_annotation.dart';

part 'sales.g.dart';

@JsonSerializable()
class Sales {
  final DateTime date;
  final int kioskId;
  final String? operator;
  final int total;
  final int kioskProfit;
  final int cash;
  final int? powerCost;
  final int lastDebt;
  final bool? receipt;
  final bool fundTransferred;

  Sales({
    required this.date,
    required this.kioskId,
    this.operator,
    required this.total,
    required this.kioskProfit,
    required this.cash,
    this.powerCost,
    required this.lastDebt,
    this.receipt,
    required this.fundTransferred,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => _$SalesFromJson(json);
  Map<String, dynamic> toJson() => _$SalesToJson(this);
}
