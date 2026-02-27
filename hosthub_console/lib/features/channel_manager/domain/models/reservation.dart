import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
sealed class Reservation with _$Reservation {
  const Reservation._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Reservation({
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
