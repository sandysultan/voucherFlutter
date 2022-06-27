import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'fund_request.g.dart';

@JsonSerializable()
class FundRequest {
  final int? id;
  final int total;
  final String? requestedBy;
  final String? description;
  final int expenseTypeId;
  @JsonKey(name: "fund_request_details")
  final List<FundRequestDetail> fundRequestDetails;
  final User? requestedByUser;
  @JsonKey(name: "expense_type")
  final ExpenseType? expenseType;
  final DateTime? createdAt;

  FundRequest(
      {this.id,
        this.requestedBy,
        required this.expenseTypeId,
        required this.fundRequestDetails,
        this.requestedByUser,
        this.expenseType,
        this.description,
        required this.total,
        this.createdAt,
      });

  factory FundRequest.fromJson(Map<String, dynamic> json) =>
      _$FundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FundRequestToJson(this);
}
