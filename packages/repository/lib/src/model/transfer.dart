import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'transfer.g.dart';

@JsonSerializable()
class Transfer {
  final int? id;
  final String? operator;
  final int total;
  final List<int>? salesIds;


  Transfer({
    this.id,
    this.operator,
    required this.total,
    this.salesIds,
  });


  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);
  Map<String, dynamic> toJson() => _$TransferToJson(this);
}
