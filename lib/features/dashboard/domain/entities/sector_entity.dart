import 'package:equatable/equatable.dart';

class Sector extends Equatable {
  const Sector({
    required this.sectorId,
    required this.name,
    this.description,
  });

  final String sectorId;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [sectorId, name, description];
}
