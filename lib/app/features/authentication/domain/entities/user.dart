import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String? email;
  final String? phone;
  final String? name;
  final String? role;

  const User({
    this.id,
    this.email,
    this.phone,
    this.name,
    this.role,
  });

  @override
  List<Object?> get props => [id, email, phone, name, role];
}
