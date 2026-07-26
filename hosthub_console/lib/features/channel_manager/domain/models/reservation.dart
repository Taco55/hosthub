import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
sealed class Reservation with _$Reservation {
  const Reservation._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Reservation({
    /// The property this booking belongs to — the console's own
    /// `properties.id`, never the channel manager's id.
    ///
    /// Required, because every aggregate is `property_id IN (:selection)` rather
    /// than "the current property": a booking that cannot say which property it
    /// is for cannot be costed, counted or filtered.
    required int propertyId,
    String? reservationId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    int? guestCount,
    int? adultCount,
    int? childCount,
    int? infantCount,
    String? source,
    String? notes,
    num? totalAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, dynamic>{})
    Map<String, dynamic> raw,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
