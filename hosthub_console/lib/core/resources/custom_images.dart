import 'package:flutter/material.dart';

class CustomImage {
  CustomImage._();

  static const AssetImage googleIcon = AssetImage(
    'lib/core/resources/assets/images/google_ios_neutral.png',
  );

  static const _channelBase = 'assets/channel_images';

  static const AssetImage airbnbIcon = AssetImage('$_channelBase/airbnb.png');
  static const AssetImage bookingIcon = AssetImage('$_channelBase/booking.png');
  static const AssetImage vrboIcon = AssetImage('$_channelBase/vrbo.png');
  static const AssetImage expediaIcon = AssetImage('$_channelBase/expedia.png');
  static const AssetImage lodgifyIcon = AssetImage('$_channelBase/lodgify.png');
}
