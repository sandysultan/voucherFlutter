part of 'asset_bloc.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();
  @override
  List<Object?> get props => [];
}

class GetGroups extends AssetEvent {
}


class GetAsset extends AssetEvent {
  final String groupName;
  final int year;
  final int month;

  const GetAsset(this.groupName, this.year, this.month);
}