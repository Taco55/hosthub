import 'package:hosthub_console/core/services/lodgify_service.dart';
import 'package:hosthub_console/features/user_settings/data/lodgify_repository.dart';

class LodgifyRepositoryImpl implements LodgifyRepository {
  LodgifyRepositoryImpl({required LodgifyService lodgifyService})
    : _lodgifyService = lodgifyService;

  final LodgifyService _lodgifyService;

  @override
  Future<List<LodgifyPropertySummary>> fetchProperties() {
    return _lodgifyService.fetchProperties();
  }

  @override
  Future<List<LodgifyCalendarEntry>> fetchCalendar(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) {
    return _lodgifyService.fetchCalendar(
      propertyId,
      start: start,
      end: end,
    );
  }

  @override
  Future<void> testConnection() async {
    await _lodgifyService.fetchProperties();
  }
}
