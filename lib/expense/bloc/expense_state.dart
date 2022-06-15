part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object> get props => [];
}

class ExpensePageInitial extends ExpenseState {
}


class GetGroupLoading extends ExpenseState {
}

class GetGroupSuccess extends ExpenseState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends ExpenseState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseLoading extends ExpenseState {
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class ExpenseEmpty extends ExpenseState {
  final String message;

  const ExpenseEmpty(this.message);

  @override
  List<Object> get props => [message];

}

class AddExpenseLoading extends ExpenseState {
}

class AddExpenseError extends ExpenseState {
  final String message;

  const AddExpenseError(this.message);

  @override
  List<Object> get props => [message];

}

class AddExpenseSuccess extends ExpenseState {
  final Expense expense;

  const AddExpenseSuccess(this.expense);

  @override
  List<Object> get props => [expense];

}

class GetExpenseTypeLoading extends ExpenseState {
}

class GetExpenseTypeSuccess extends ExpenseState {

  final List<ExpenseType> expenseTypes;

  const GetExpenseTypeSuccess(this.expenseTypes);

  @override
  List<Object> get props => [expenseTypes];
}

class GetExpenseTypeError extends ExpenseState {
  final String message;

  const GetExpenseTypeError(this.message);

  @override
  List<Object> get props => [message];
}