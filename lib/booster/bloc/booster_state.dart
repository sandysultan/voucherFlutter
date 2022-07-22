part of 'booster_bloc.dart';

abstract class BoosterState extends Equatable {
  const BoosterState();
  @override
  List<Object> get props => [];
}

class BoosterInitial extends BoosterState {
}



class GetGroupLoading extends BoosterState {
}

class GetGroupSuccess extends BoosterState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends BoosterState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}



class GetBoosterLoading extends BoosterState {
}

class GetBoosterSuccess extends BoosterState {
  final List<Booster> boosters;

  const GetBoosterSuccess(this.boosters);

  @override
  List<Object> get props => [boosters];
}

class GetBoosterFailed extends BoosterState {
  final String message;

  const GetBoosterFailed(this.message);

  @override
  List<Object> get props => [message];
}



class DeactivateBoosterLoading extends BoosterState {
}

class DeactivateBoosterSuccess extends BoosterState {
  const DeactivateBoosterSuccess();
}

class DeactivateBoosterFailed extends BoosterState {
  final String message;

  const DeactivateBoosterFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetInvestorLoading extends BoosterState {
}

class GetInvestorSuccess extends BoosterState {
  final List<rep.User> users;

  const GetInvestorSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetInvestorFailed extends BoosterState {
  final String message;

  const GetInvestorFailed(this.message);

  @override
  List<Object> get props => [message];
}


class AddBoostLoading extends BoosterState {
}

class AddBoostSuccess extends BoosterState {

}

class AddBoostFailed extends BoosterState {
  final String message;

  const AddBoostFailed(this.message);

  @override
  List<Object> get props => [message];
}