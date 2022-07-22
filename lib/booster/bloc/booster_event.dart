part of 'booster_bloc.dart';

abstract class BoosterEvent extends Equatable {
  const BoosterEvent();
  @override
  List<Object?> get props => [];
}

class GetGroups extends BoosterEvent {
  final String module;
  const GetGroups(this.module);
  @override
  List<Object?> get props => [module];
}

class GetBooster extends BoosterEvent {
  final String groupName;
  const GetBooster(this.groupName);
  @override
  List<Object?> get props => [groupName];
}

class DeactivateBooster extends BoosterEvent {
  final int id;
  const DeactivateBooster(this.id);
  @override
  List<Object?> get props => [id];
}


class GetInvestor extends BoosterEvent {
  final String groupName;

  const GetInvestor(this.groupName);

  @override
  List<Object?> get props => [groupName];
}


class AddBoost extends BoosterEvent {
  final Booster booster;
  const AddBoost(this.booster);
  @override
  List<Object?> get props => [booster];
}