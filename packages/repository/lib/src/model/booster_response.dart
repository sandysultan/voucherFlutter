import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'booster_response.g.dart';

@JsonSerializable()
class BoosterResponse extends BaseResponse {
  final List<Booster> boosters;

  BoosterResponse(
      {required int status, required String message,required this.boosters,})
      : super(status: status, message: message);

  factory BoosterResponse.fromJson(Map<String, dynamic> json) =>
      _$BoosterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BoosterResponseToJson(this);
}
