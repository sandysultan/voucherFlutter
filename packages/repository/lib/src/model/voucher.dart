import 'package:json_annotation/json_annotation.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/model/app_module.dart';

part 'voucher.g.dart';

@JsonSerializable()
class Voucher{
  final int id;
  final String name;
  final int price;

  Voucher({required this.id,
    required this.name,
    required this.price,
  });


  factory Voucher.fromJson(Map<String, dynamic> json) =>
      _$VoucherFromJson(json);
  Map<String, dynamic> toJson() => _$VoucherToJson(this);
}