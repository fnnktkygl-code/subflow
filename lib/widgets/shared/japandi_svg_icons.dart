import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Japanese minimalist monoline SVG icon library for Japandi design.
enum JapandiSvgType {
  home,
  calendar,
  subscriptions,
  settings,
  add,
  wallet,
  leaf,
  chart,
  bell,
  check,
  close,
  search,
  sparkles,
}

class JapandiSvgIcon extends StatelessWidget {
  final JapandiSvgType type;
  final double size;
  final Color? color;

  const JapandiSvgIcon({
    super.key,
    required this.type,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    final colorHex = '#${effectiveColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    final svgString = _getSvgString(type, colorHex);

    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  static String _getSvgString(JapandiSvgType type, String colorHex) {
    switch (type) {
      case JapandiSvgType.home:
        // Japanese Torii / Minimalist Pavilion Home
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 10.5L12 3.5L21 10.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M5.5 9V19.5C5.5 20.05 5.95 20.5 6.5 20.5H17.5C18.05 20.5 18.5 20.05 18.5 19.5V9" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M10 20.5V14.5C10 13.95 10.45 13.5 11 13.5H13C13.55 13.5 14 13.95 14 14.5V20.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.calendar:
        // Japanese Tatami Grid & Lunar Schedule
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3.5" y="5" width="17" height="15.5" rx="3.5" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M3.5 9.5H20.5" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M8 3V6.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M16 3V6.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <circle cx="8" cy="14" r="1.2" fill="$colorHex"/>
  <circle cx="12" cy="14" r="1.2" fill="$colorHex"/>
  <circle cx="16" cy="14" r="1.2" fill="$colorHex"/>
  <circle cx="8" cy="17" r="1.2" fill="$colorHex"/>
  <circle cx="12" cy="17" r="1.2" fill="$colorHex"/>
</svg>''';

      case JapandiSvgType.subscriptions:
        // Japanese Kamon Emblem / Washi Card Stack
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="4" width="16" height="16" rx="4" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M8 9H16" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M8 13H16" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M8 17H12.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case JapandiSvgType.settings:
        // Japanese Torii / Zen Cog
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="3.5" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M12 2.5V5.5M12 18.5V21.5M2.5 12H5.5M18.5 12H21.5M5.3 5.3L7.4 7.4M16.6 16.6L18.7 18.7M5.3 18.7L7.4 16.6M16.6 7.4L18.7 5.3" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case JapandiSvgType.add:
        // Japanese Ensō Circle + Minimal Cross
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 7V17M7 12H17" stroke="$colorHex" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.wallet:
        // Traditional Inrou Purse / Minimal Wallet
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="6" width="18" height="13" rx="3.5" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M16 11.5C16 10.95 16.45 10.5 17 10.5H21V14.5H17C16.45 14.5 16 14.05 16 13.5V11.5Z" stroke="$colorHex" stroke-width="1.8"/>
  <circle cx="18" cy="12.5" r="0.8" fill="$colorHex"/>
  <path d="M7 6V4.5C7 3.95 7.45 3.5 8 3.5H16C16.55 3.5 17 3.95 17 4.5V6" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case JapandiSvgType.leaf:
        // Matcha Leaf / Bonsai
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 21C12 21 12 14 12 9C12 4 7 3 7 3C7 3 6 8 8 13C10 18 12 21 12 21Z" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 9C12 4 17 3 17 3C17 3 18 8 16 13C14 18 12 21 12 21" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.chart:
        // Bokashi Trend Wave / Insights
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 19.5H20" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M5 14.5L10 9.5L14 13L19 6.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M15.5 6.5H19V10" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.bell:
        // Japanese Temple Bell / Rin
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 16.5H6C6.5 15.5 7.5 14.5 7.5 11C7.5 8.5 9.5 6.5 12 6.5C14.5 6.5 16.5 8.5 16.5 11C16.5 14.5 17.5 15.5 18 16.5Z" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M10.5 19.5C10.8 20.2 11.3 20.5 12 20.5C12.7 20.5 13.2 20.2 13.5 19.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M12 3.5V6.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case JapandiSvgType.check:
        // Sumi Stroke Checkmark
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5 12.5L9.5 17L19 7.5" stroke="$colorHex" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.close:
        // Minimal Cross
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M6 6L18 18M18 6L6 18" stroke="$colorHex" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case JapandiSvgType.search:
        // Minimalist Monoline Lens
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="11" cy="11" r="6.5" stroke="$colorHex" stroke-width="1.8"/>
  <path d="M16 16L20.5 20.5" stroke="$colorHex" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case JapandiSvgType.sparkles:
        // Sakura Blossom Star
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 3C12 7.5 16.5 12 21 12C16.5 12 12 16.5 12 21C12 16.5 7.5 12 3 12C7.5 12 12 7.5 12 3Z" stroke="$colorHex" stroke-width="1.8" stroke-linejoin="round"/>
</svg>''';
    }
  }
}
