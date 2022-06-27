part of 'fund_request_bloc.dart';

abstract class FundRequestEvent extends Equatable {
  const FundRequestEvent();

  @override
  List<Object?> get props => [];
}

class GetGroups extends FundRequestEvent {}

class GetPaid extends FundRequestEvent {
  final int year;
  final int month;

  const GetPaid({required this.year, required this.month});

  @override
  List<Object?> get props => [year,month];
}

class GetUnpaid extends FundRequestEvent {}

class GetExpenseType extends FundRequestEvent {}

class GetFinanceUsers extends FundRequestEvent {}

class AddFundRequest extends FundRequestEvent {
  final int total;
  final String? requestedBy;
  final ExpenseType expenseType;
  final String imagePath;
  final String? description;
  final List<String> groups;

  const AddFundRequest({
    required this.total,
    this.requestedBy,
    required this.expenseType,
    required this.imagePath,
    required this.groups,
    this.description,
  });

  @override
  List<Object?> get props => [
        total,
        expenseType,
        imagePath,
        groups,
        if (requestedBy != null) ...[requestedBy]
      ];
}

class GetModulesPay extends FundRequestEvent {}
