import 'package:json_annotation/json_annotation.dart';

/// The channel a guest conversation arrived through.
///
/// **Not the source.** The source is where the console fetched the thread from
/// (Lodgify); the channel is where the guest is (Airbnb). One Lodgify account
/// delivers Airbnb, Booking.com and direct conversations at once — which is
/// exactly why an inbox is worth building, and why the channel belongs to a
/// thread rather than to a repository.
@JsonEnum(fieldRename: FieldRename.snake)
enum MessageChannel {
  airbnb,
  bookingCom,
  vrbo,
  direct,
  email,
  other;

  /// The stored key, and the string [BookingSourceIcon] resolves a logo from.
  ///
  /// Reusing that resolver is deliberate: one guest keeps one colour and one
  /// abbreviation across Boekingen, Omzet and Berichten.
  String get sourceKey {
    switch (this) {
      case MessageChannel.airbnb:
        return 'airbnb';
      case MessageChannel.bookingCom:
        return 'booking';
      case MessageChannel.vrbo:
        return 'vrbo';
      case MessageChannel.direct:
        return 'direct';
      case MessageChannel.email:
        return 'email';
      case MessageChannel.other:
        return 'other';
    }
  }

  /// The channel a stored value or a provider's source string means.
  static MessageChannel fromKey(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return MessageChannel.other;
    if (normalized.contains('airbnb')) return MessageChannel.airbnb;
    if (normalized.contains('booking')) return MessageChannel.bookingCom;
    if (normalized.contains('vrbo') || normalized.contains('homeaway')) {
      return MessageChannel.vrbo;
    }
    if (normalized.contains('mail')) return MessageChannel.email;
    if (normalized.contains('direct') ||
        normalized.contains('manual') ||
        normalized.contains('website') ||
        normalized.contains('owner')) {
      return MessageChannel.direct;
    }
    return MessageChannel.other;
  }
}
