import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'sales_detail.g.dart';

@JsonSerializable()
class SalesDetail{
  final int? salesId;
  final int voucherId;
  final int price;
  final int stock;
  final int balance;
  final int damage;
  final int restock;
  final Voucher? voucher;

  SalesDetail({
    this.salesId,
    required this.voucherId,
    required this.price,
    required this.stock,
    required this.balance,
    required this.damage,
    required this.restock,
    this.voucher,
  });


  factory SalesDetail.fromJson(Map<String, dynamic> json) =>
      _$SalesDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SalesDetailToJson(this);
}