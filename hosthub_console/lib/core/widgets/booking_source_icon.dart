import 'package:flutter/material.dart';
import '../resources/custom_images.dart';

/// Displays the favicon / logo of a booking channel based on the source string.
///
/// Falls back to a coloured circle with the first letter when no logo matches.
class BookingSourceIcon extends StatelessWidget {
  const BookingSourceIcon({super.key, required this.source, this.size = 18});

  final String? source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final info = _resolve(source);

    if (info.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image(
          image: info.image!,
          width: size,
          height: size,
          filterQuality: FilterQuality.medium,
        ),
      );
    }

    // Fallback: coloured circle with initial.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        info.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  /// Lighter bar colour per source, used for timeline calendar entries.
  static Color barColor(String? source) {
    final s = source?.toLowerCase().trim() ?? '';
    if (s.contains('airbnb')) return const Color(0xFFFFE0E0);
    if (s.contains('booking')) return const Color(0xFFD6E4F7);
    if (s.contains('vrbo') || s.contains('homeaway')) {
      return const Color(0xFFD9E0F7);
    }
    if (s.contains('direct') || s.contains('owner') || s.contains('manual')) {
      return const Color(0xFFD4F0E5);
    }
    if (s.contains('expedia')) return const Color(0xFFFFF3D0);
    return const Color(0xFFE8E0F0);
  }

  /// Resolve a human-readable label for a source.
  static String label(String? source) => _resolve(source).name;

  static _SourceInfo _resolve(String? source) {
    final s = source?.toLowerCase().trim() ?? '';
    if (s.contains('airbnb')) {
      return _SourceInfo(
        image: CustomImage.airbnbIcon,
        color: const Color(0xFFFF5A5F),
        label: 'A',
        name: 'Airbnb',
      );
    }
    if (s.contains('booking')) {
      return _SourceInfo(
        image: CustomImage.bookingIcon,
        color: const Color(0xFF003580),
        label: 'B',
        name: 'Booking.com',
      );
    }
    if (s.contains('vrbo') || s.contains('homeaway')) {
      return _SourceInfo(
        image: CustomImage.vrboIcon,
        color: const Color(0xFF3B5998),
        label: 'V',
        name: 'VRBO',
      );
    }
    if (s.contains('expedia')) {
      return _SourceInfo(
        image: CustomImage.expediaIcon,
        color: const Color(0xFFFFCC00),
        label: 'E',
        name: 'Expedia',
      );
    }
    if (s.contains('direct') ||
        s.contains('owner') ||
        s.contains('manual') ||
        s.contains('website') ||
        s.contains('lodgify')) {
      return _SourceInfo(
        image: CustomImage.lodgifyIcon,
        color: const Color(0xFF099773),
        label: 'W',
        name: 'Website',
      );
    }
    if (s.isEmpty) {
      return _SourceInfo(
        image: null,
        color: const Color(0xFF9E9E9E),
        label: '?',
        name: '-',
      );
    }
    return _SourceInfo(
      image: null,
      color: const Color(0xFF607D8B),
      label: s[0].toUpperCase(),
      name: source ?? '-',
    );
  }
}

class _SourceInfo {
  const _SourceInfo({
    required this.image,
    required this.color,
    required this.label,
    required this.name,
  });

  final AssetImage? image;
  final Color color;
  final String label;
  final String name;
}
