import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'asset_response.g.dart';

@JsonSerializable()
class AssetResponse extends BaseResponse {
  final List<Asset> assets;

  AssetResponse(
      {required int status, required String message,required this.assets,})
      : super(status: status, message: message);

  factory AssetResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AssetResponseToJson(this);
}
