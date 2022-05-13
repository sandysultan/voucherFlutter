import 'package:json_annotation/json_annotation.dart';
import 'package:repository/repository.dart';

part 'add_sales.g.dart';

@JsonSerializable(explicitToJson: true)
class AddSales extends Sales{
  final List<SalesDetail> details;

  AddSales({
    required DateTime date,
    required int kioskId,
    String? operator,
    required int subtotal,
    required int kioskProfit,
    required int cash,
    required int powerCost,
    required int total,
    bool? receipt,
    required this.details
  }):super(
      id: null,
      date:date,
      kioskId:kioskId,
      operator:operator,
      subtotal:subtotal,
      kioskProfit:kioskProfit,
      cash:cash,
      powerCost:powerCost,
      total:total,
      receipt:receipt,
  fundTransferred: false);


  factory AddSales.fromJson(Map<String, dynamic> json) =>
      _$AddSalesFromJson(json);
  Map<String, dynamic> toJson() => _$AddSalesToJson(this);
}