/// The channels a booking can arrive through.
///
/// The console has always resolved a channel by searching the provider's own
/// source string ("Airbnb", "booking.com", "Manual"). That search lives here
/// once, and every tier — account defaults, property overrides, settlement —
/// keys on this enum rather than on a string. Two spellings of one channel can
/// therefore never resolve to two different configurations.
enum BookingChannel {
  booking,
  airbnb,

  /// Direct bookings and anything the provider does not name.
  other,
}

/// The stored key for a channel, and the key it carries in the two settings
/// payloads (`properties.channel_settings`, the account defaults).
extension BookingChannelKey on BookingChannel {
  String get key {
    switch (this) {
      case BookingChannel.booking:
        return 'booking';
      case BookingChannel.airbnb:
        return 'airbnb';
      case BookingChannel.other:
        return 'other';
    }
  }
}

/// The channel a stored key names, or null when the key is not one of ours.
///
/// Distinct from [bookingChannelForSource]: that one *searches* a provider's
/// free-form source string, this one reads a value the console itself wrote.
/// Returning null rather than falling back to `other` matters at the storage
/// boundary — a row with an unrecognised channel is a schema problem, not a
/// direct booking.
BookingChannel? bookingChannelForKey(String? key) {
  final normalized = key?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  for (final channel in BookingChannel.values) {
    if (channel.key == normalized) return channel;
  }
  return null;
}

/// Which channel a provider's source string means.
BookingChannel bookingChannelForSource(String? source) {
  final normalized = source?.trim().toLowerCase() ?? '';
  if (normalized.contains('booking')) return BookingChannel.booking;
  if (normalized.contains('airbnb')) return BookingChannel.airbnb;
  return BookingChannel.other;
}
