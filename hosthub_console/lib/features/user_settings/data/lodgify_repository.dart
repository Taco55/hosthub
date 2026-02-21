import 'package:hosthub_console/shared/services/lodgify_service.dart';

abstract class LodgifyRepository {
  Future<List<LodgifyPropertySummary>> fetchProperties();
  Future<List<LodgifyCalendarEntry>> fetchCalendar(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  });
  Future<void> testConnection();
}
