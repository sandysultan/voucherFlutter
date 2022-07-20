import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'sales.g.dart';

@JsonSerializable()
class Sales {
  final int? id;
  final DateTime? date;
  final int kioskId;
  final String? operator;
  final String? description;
  final int subtotal;
  final int kioskProfit;
  final int cash;
  final int debt;
  final int powerCost;
  final int total;
  final bool? receipt;
  final bool fundTransferred;
  @JsonKey(name: 'operator_user')
  final User? operatorUser;
  final Kiosk? kiosk;

  @JsonKey(name:'sales_details')
  final List<SalesDetail>? salesDetails;

  final bool isClosed;

  Sales( {
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
    this.operatorUser,
    this.description,
    this.kiosk,
    this.isClosed=false,
  });

  Sales copy({

    int? id,
    DateTime? date,
    int? kioskId,
    String? operator,
    String? description,
    int? subtotal,
    int? kioskProfit,
    int? cash,
    int? debt,
    int? powerCost,
    int? total,
    bool? receipt,
    bool? fundTransferred,
    List<SalesDetail>? salesDetails,
    User? operatorUser,
    bool? isClosed,
  }){
    return Sales(
        id: id??this.id,
      date: date??this.date,
      kioskId: kioskId??this.kioskId,
      operator: operator??this.operator,
      description: description??this.description,
      subtotal: subtotal??this.subtotal,
      kioskProfit: kioskProfit??this.kioskProfit,
      cash: cash??this.cash,
      debt: debt??this.debt,
      powerCost: powerCost??this.powerCost,
      total: total??this.total,
      receipt: receipt??this.receipt,
      fundTransferred: fundTransferred??this.fundTransferred,
      salesDetails: salesDetails??this.salesDetails,
      operatorUser: operatorUser??this.operatorUser,
      isClosed: isClosed??this.isClosed,
    );
  }

  factory Sales.fromJson(Map<String, dynamic> json) => _$SalesFromJson(json);
  Map<String, dynamic> toJson() => _$SalesToJson(this);
}
