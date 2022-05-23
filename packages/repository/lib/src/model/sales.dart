import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'sales.g.dart';

@JsonSerializable()
class Sales {
  final int? id;
  final DateTime? date;
  final int kioskId;
  final String? operator;
  final int subtotal;
  final int kioskProfit;
  final int cash;
  final int debt;
  final int powerCost;
  final int total;
  final bool? receipt;
  final bool fundTransferred;
  final User? user;
  final Kiosk? kiosk;

  @JsonKey(name:'sales_details')
  final List<SalesDetail>? salesDetails;

  Sales({
    this.id,
    this.date,
    required this.kioskId,
    this.operator,
    required this.subtotal,
    required this.kioskProfit,
    required this.cash,
    required this.debt,
    required this.powerCost,
    required this.total,
    this.receipt,
    required this.fundTransferred,
    this.salesDetails,
    this.user,
    this.kiosk,
  });

  Sales copy({

    int? id,
    DateTime? date,
    int? kioskId,
    String? operator,
    int? subtotal,
    int? kioskProfit,
    int? cash,
    int? debt,
    int? powerCost,
    int? total,
    bool? receipt,
    bool? fundTransferred,
    List<SalesDetail>? salesDetails,
    User? user,
  }){
    return Sales(
        id: id??this.id,
      date: date??this.date,
      kioskId: kioskId??this.kioskId,
      operator: operator??this.operator,
      subtotal: subtotal??this.subtotal,
      kioskProfit: kioskProfit??this.kioskProfit,
      cash: cash??this.cash,
      debt: debt??this.debt,
      powerCost: powerCost??this.powerCost,
      total: total??this.total,
      receipt: receipt??this.receipt,
      fundTransferred: fundTransferred??this.fundTransferred,
      salesDetails: salesDetails??this.salesDetails,
      user: user??this.user,
    );
  }

  factory Sales.fromJson(Map<String, dynamic> json) => _$SalesFromJson(json);
  Map<String, dynamic> toJson() => _$SalesToJson(this);
}
