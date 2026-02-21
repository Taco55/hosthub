import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';

/// Abstract interface for any channel manager (Lodgify, Beds24, Guesty, etc.).
///
/// Implementations handle API-specific DTOs and map to/from these
/// channel-agnostic domain models.
abstract class ChannelManagerRepository {
  /// Fetch all properties from the channel manager.
  Future<List<ChannelProperty>> fetchProperties();

  /// Fetch reservations/calendar entries for a specific property.
  Future<List<Reservation>> fetchReservations(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  });

  /// Update the internal notes for a reservation.
  Future<void> updateReservationNotes(
    String reservationId,
    String notes,
  );

  /// Fetch nightly rates for a property within a date range.
  ///
  /// Returns a record with a map of date (midnight) → nightly rate amount
  /// and the optional currency code from the channel manager's settings.
  Future<({Map<DateTime, num> rates, String? currency})> fetchNightlyRates(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  });

  /// Test the connection to the channel manager (validates API key, etc.).
  Future<void> testConnection();
}
