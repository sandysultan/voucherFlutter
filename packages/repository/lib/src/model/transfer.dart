import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'transfer.g.dart';

@JsonSerializable()
class Transfer {
  final int? id;
  final String? operator;
  final int total;
  final DateTime? createdAt;
  final List<int>? salesIds;
  final List<Sales>? sales;


  Transfer({
    this.id,
    this.operator,
    required this.total,
    this.createdAt,
    this.salesIds,
    this.sales,
  });


  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);
  Map<String, dynamic> toJson() => _$TransferToJson(this);
}
