import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/core/services/api_services/api_parsing.dart';

/// Lodgify-specific DTO for property details data.
///
/// Handles all the flexible key-name variations from Lodgify's API
/// and maps to the channel-agnostic [ChannelPropertyDetails] domain model.
class LodgifyPropertyDetailsDto {
  const LodgifyPropertyDetailsDto({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  factory LodgifyPropertyDetailsDto.fromMap(Map<String, dynamic> map) {
    return LodgifyPropertyDetailsDto(
      id: map.readString(const ['id', 'property_id', 'propertyId']),
      name: map.readString(const ['name', 'property_name', 'title']),
      raw: map,
    );
  }

  ChannelPropertyDetails toDomain() {
    return ChannelPropertyDetails(id: id, name: name, raw: raw);
  }
}
