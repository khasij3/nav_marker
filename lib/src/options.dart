import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class NavMarkerSettings {
  const NavMarkerSettings({
    this.size = 75.0,
    this.arrowColor = Colors.blue,
    this.backgroundColor = Colors.blue,
    this.surfaceColor = Colors.white,
    this.image,
    this.child,
    this.onTap,
  }) : assert(
          image == null || child == null,
          'Cannot provide both a icon and a child\n'
          '[image] For default only set image as body\n'
          '[child] For customizing the body',
        );

  /// To set size of the navigator as [double]
  final double size;

  /// To set color of the navigator's arrow
  /// If not specified, the default is [Colors.blue]
  /// If not specified and the [backgroundColor] is specified,
  /// then the default value will depend on the [backgroundColor]
  final Color arrowColor;

  /// To set color of the navigator's background
  /// If not specified, the default is [Colors.blue]
  final Color backgroundColor;

  /// To set color of the navigator's background
  /// If not specified, the default is [Colors.white]
  final Color surfaceColor;

  /// Add image to be displayed on the navigator body
  /// If [image] is set, [child] cannot be set
  final ImageProvider? image;

  /// Add widget to be displayed on the navigator body
  /// If [child] is set, [image] cannot be set
  final Widget? child;

  /// Action on tap the navigator body
  final VoidCallback? onTap;
}

typedef VoidCallback = void Function(LatLng targetPoint);
