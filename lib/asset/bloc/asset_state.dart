part of 'asset_bloc.dart';

abstract class AssetState extends Equatable {
  const AssetState();
  @override
  List<Object> get props => [];
}

class AssetInitial extends AssetState {
}


class GetGroupLoading extends AssetState {
}

class GetGroupSuccess extends AssetState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends AssetState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetAssetLoading extends AssetState {
}

class GetAssetSuccess extends AssetState {
  final List<Asset> assets;

  const GetAssetSuccess(this.assets);

  @override
  List<Object> get props => [assets];
}

class GetAssetFailed extends AssetState {
  final String message;

  const GetAssetFailed(this.message);

  @override
  List<Object> get props => [message];
}


