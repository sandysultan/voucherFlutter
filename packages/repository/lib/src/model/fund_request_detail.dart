import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/expense.dart';

part 'fund_request_detail.g.dart';

@JsonSerializable()
class FundRequestDetail {
  final int? fundRequestId;
  final double? percentage;
  final String groupName;
  final int? expenseId;
  final Expense? expense;

  FundRequestDetail(
      {this.fundRequestId,
      this.percentage,
      required this.groupName,
      this.expenseId,
      this.expense,
      });

  factory FundRequestDetail.fromJson(Map<String, dynamic> json) =>
      _$FundRequestDetailFromJson(json);

  Map<String, dynamic> toJson() => _$FundRequestDetailToJson(this);

  FundRequestDetail copy({
    int? fundRequestId,
    double? percentage,
    String? groupName,
    int? expenseId,
    Expense? expense,
  }) {
    return FundRequestDetail(
        fundRequestId: fundRequestId??this.fundRequestId,
      percentage: percentage??this.percentage,
      groupName: groupName??this.groupName,
      expenseId: expenseId??this.expenseId,
      expense: expense??this.expense,
    );
  }
}
