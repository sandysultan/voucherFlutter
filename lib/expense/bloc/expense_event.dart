part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class GetGroups extends ExpenseEvent{
}

class GetExpenseType extends ExpenseEvent{
}

class PayFundRequest extends ExpenseEvent{
  final String imagePath;

  const PayFundRequest(this.imagePath);

  @override
  List<Object?> get props => [];
}


class ExpenseRefresh extends ExpenseEvent{
  final String groupName;
  final int year;
  final int month;

  const ExpenseRefresh({required this.groupName, required this.year, required this.month});

  @override
  List<Object?> get props => [groupName,year,month];

}

class AddExpense extends ExpenseEvent{
  final Expense expense;
  final File receipt;

  const AddExpense(this.expense, this.receipt);

  @override
  List<Object?> get props => [expense,receipt];
}



class GetLastClosing extends ExpenseEvent{

  final String groupName;
  const GetLastClosing({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}

