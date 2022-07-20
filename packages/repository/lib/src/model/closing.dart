import 'package:json_annotation/json_annotation.dart';


part 'closing.g.dart';

@JsonSerializable()
class Closing{
  final int id;
  final String groupName;
  final int year;
  final int month;

  Closing( {required this.groupName,required this.id, required this.year, required this.month,
  });


  factory Closing.fromJson(Map<String, dynamic> json) =>
      _$ClosingFromJson(json);
  Map<String, dynamic> toJson() => _$ClosingToJson(this);
}