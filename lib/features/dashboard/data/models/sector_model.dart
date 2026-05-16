import '../../domain/entities/sector_entity.dart';

class SectorModel extends Sector {
  const SectorModel({
    required super.sectorId,
    required super.name,
    super.description,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) => SectorModel(
        sectorId: json['sector_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}
