import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final List<Sales>? sales;
  @JsonKey(name: 'user_roles')
  final List<UserRole>? userRoles;

  User({required this.uid, required this.email, required this.name,
    this.phone, this.sales,this.userRoles
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copy({String? uid,
    String? email,
    String? name,
    String? phone,
    List<Sales>? sales,
  }) {
    return User(uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      sales: sales ?? this.sales,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              uid == other.uid &&
              email == other.email &&
              name == other.name &&
              phone == other.phone;

  @override
  int get hashCode =>
      uid.hashCode ^ email.hashCode ^ name.hashCode ^ phone.hashCode;
}