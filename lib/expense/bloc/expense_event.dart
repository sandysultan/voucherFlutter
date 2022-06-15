part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}


class GetGroups extends ExpenseEvent{
  const GetGroups();
}



class GetExpenseType extends ExpenseEvent{
  const GetExpenseType();
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

