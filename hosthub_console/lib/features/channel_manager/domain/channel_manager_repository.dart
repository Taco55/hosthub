import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';

/// Abstract interface for any channel manager (Lodgify, Beds24, Guesty, etc.).
///
/// Implementations handle API-specific DTOs and map to/from these
/// channel-agnostic domain models.
abstract class ChannelManagerRepository {
  /// Fetch all properties from the channel manager.
  Future<List<ChannelProperty>> fetchProperties();

  /// Fetch the full record of one property from the channel manager.
  ///
  /// [fetchProperties] only carries what property discovery needs (id + name);
  /// this is the call that returns the fields the console mirrors onto its own
  /// property row.
  Future<ChannelPropertyDetails> fetchPropertyDetails(String propertyId);

  /// Fetch reservations/calendar entries for a specific property.
  ///
  /// Both ids are required and they are not interchangeable:
  /// [channelPropertyId] addresses the channel manager, [propertyId] is the
  /// console's own `properties.id` that every returned booking is tagged with.
  /// Naming them apart is deliberate — the two used to share the name
  /// `propertyId`, and the channel's id reached code that filtered on ours.
  Future<List<Reservation>> fetchReservations({
    required int propertyId,
    required String channelPropertyId,
    DateTime? start,
    DateTime? end,
  });

  /// Update the internal notes for a reservation.
  Future<void> updateReservationNotes(String reservationId, String notes);

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
