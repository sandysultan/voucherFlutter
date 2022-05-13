import 'package:json_annotation/json_annotation.dart';

part 'sales_detail.g.dart';

@JsonSerializable()
class SalesDetail{
  final int? salesId;
  final int voucherId;
  final int price;
  final int stock;
  final int balance;
  final int restock;

  SalesDetail({
    this.salesId,
    required this.voucherId,
    required this.price,
    required this.stock,
    required this.balance,
    required this.restock,
  });


  factory SalesDetail.fromJson(Map<String, dynamic> json) =>
      _$SalesDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SalesDetailToJson(this);
}