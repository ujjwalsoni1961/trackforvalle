import 'package:equatable/equatable.dart';

class UserAddressEntity extends Equatable {
  final String streetAddress;
  final String city;
  final String state;

  const UserAddressEntity({
    required this.streetAddress,
    required this.city,
    required this.state,
  });

  @override
  List<Object?> get props => [streetAddress, city, state];
}
