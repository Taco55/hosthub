// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  reservationId: json['reservation_id'] as String?,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  status: json['status'] as String?,
  guestName: json['guest_name'] as String?,
  guestEmail: json['guest_email'] as String?,
  guestPhone: json['guest_phone'] as String?,
  guestCount: (json['guest_count'] as num?)?.toInt(),
  adultCount: (json['adult_count'] as num?)?.toInt(),
  childCount: (json['child_count'] as num?)?.toInt(),
  infantCount: (json['infant_count'] as num?)?.toInt(),
  source: json['source'] as String?,
  notes: json['notes'] as String?,
  totalAmount: json['total_amount'] as num?,
  currency: json['currency'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'reservation_id': instance.reservationId,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'guest_name': instance.guestName,
      'guest_email': instance.guestEmail,
      'guest_phone': instance.guestPhone,
      'guest_count': instance.guestCount,
      'adult_count': instance.adultCount,
      'child_count': instance.childCount,
      'infant_count': instance.infantCount,
      'source': instance.source,
      'notes': instance.notes,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
