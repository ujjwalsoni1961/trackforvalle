import 'package:equatable/equatable.dart';

class RegionsSubRegionEntity extends Equatable {
  final int id;
  final String name;

  const RegionsSubRegionEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
