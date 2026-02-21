import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';
import 'package:hosthub_console/shared/services/api_services/api_parsing.dart';

/// Lodgify-specific DTO for property summary data.
///
/// Handles all the flexible key-name variations from Lodgify's API
/// and maps to the channel-agnostic [ChannelProperty] domain model.
class LodgifyPropertyDto {
  const LodgifyPropertyDto({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  factory LodgifyPropertyDto.fromMap(Map<String, dynamic> map) {
    return LodgifyPropertyDto(
      id: map.readString(const ['id', 'property_id', 'propertyId']),
      name: map.readString(const ['name', 'property_name', 'title']),
      raw: map,
    );
  }

  ChannelProperty toDomain() {
    return ChannelProperty(id: id, name: name);
  }
}
