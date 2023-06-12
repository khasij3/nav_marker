import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class NavigatorLayout {
  NavigatorLayout({
    required this.mapBounds,
    required this.mapPos,
    required this.mapSize,
    required this.navSize,
    required this.targetPoint,
  });
  final LatLngBounds mapBounds;
  final Offset mapPos;
  final Size mapSize;
  final double navSize;
  final LatLng targetPoint;

  // Calculate position of the pilot on screen based on the target position

  Offset navPos() {
    final limitX = mapSize.width - navSize;
    final limitY = mapSize.height - navSize;

    // Calculate horizontal and vertical ratio
    final double horizontalRatio = (targetPoint.longitude - mapBounds.west) /
        (mapBounds.east - mapBounds.west);
    final double verticalRatio = (targetPoint.latitude - mapBounds.north) /
        (mapBounds.south - mapBounds.north);

    // Set current position on [mapSize]
    // The position is always on the edge if unbound
    double posX = (mapSize.width * horizontalRatio) - (navSize / 2);
    double posY = (mapSize.height * verticalRatio) - (navSize / 2);

    // Limited moivement of the navigator
    if (posX > limitX) posX = limitX;

    if (posX < 0) posX = 0;

    if (posY > limitY) posY = limitY;

    if (posY < 0) posY = 0;

    return Offset(posX, posY);
  }

  // Calculate direction between current point and target point
  // Then return the angle in degrees
  double navAngle() {
    // Convert params from degrees to radians
    // Required for the next calculation
    final double lat1 = degToRadian(mapBounds.center.latitude);
    final double lng1 = degToRadian(mapBounds.center.longitude);
    final double lat2 = degToRadian(targetPoint.latitude);
    final double lng2 = degToRadian(targetPoint.longitude);

    // Calculate difference in longitude
    final double dLng = lng2 - lng1;

    // Calculate [x] and [y] coordinates
    // Then calculate angle from [x] and [y]
    final double y = sin(dLng) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final double angle = atan2(y, x);

    // Convert angle back to degrees
    // And normalize the angle within 0 to 360
    double angleInDegrees = radianToDeg(angle);
    angleInDegrees = angleInDegrees % 360;

    return degToRadian(angleInDegrees);
  }

  Size areaSize() {
    final views = WidgetsBinding.instance.platformDispatcher.views.first;
    final pixelRatio = views.devicePixelRatio;

    // Size in logical pixels
    final logicalScreenSize = views.physicalSize / pixelRatio;
    final logicalWidth = logicalScreenSize.width;
    final logicalHeight = logicalScreenSize.height;

    // Safe area paddings in logical pixels
    final paddingLeft = views.padding.left / views.devicePixelRatio;
    final paddingRight = views.padding.right / views.devicePixelRatio;
    final paddingTop = views.padding.top / views.devicePixelRatio;
    final paddingBottom = views.padding.bottom / views.devicePixelRatio;

    // Safe area in logical pixels
    final safeWidth = logicalWidth - paddingLeft - paddingRight;
    final safeHeight = logicalHeight - paddingTop - paddingBottom;

    return Size(safeWidth, safeHeight);
  }
}
