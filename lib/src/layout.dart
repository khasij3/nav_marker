import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class NavigatorLayout {
  NavigatorLayout({
    required this.bounds,
    required this.angle,
    required this.boxPos,
    required this.boxSize,
    required this.navSize,
    required this.targetPoint,
  });
  final LatLngBounds bounds;

  final Offset boxPos;
  final double angle;
  final Size boxSize;
  final double navSize;
  final LatLng targetPoint;

  // Calculate position of the navigator on screen
  Offset navigatorPosition() {
    final limitX = boxSize.width - navSize;
    final limitY = boxSize.height - navSize;

    // LatLngBounds bounds = rotateLatLngBounds();

    // Calculate horizontal and vertical ratio
    final double horizontalRatio =
        (targetPoint.longitude - bounds.west) / (bounds.east - bounds.west);
    final double verticalRatio =
        (targetPoint.latitude - bounds.north) / (bounds.south - bounds.north);

    // Set current position on [boxSize]
    // The position is always on the edge if unbound
    double posX = (boxSize.width * horizontalRatio) - (navSize / 2);
    double posY = (boxSize.height * verticalRatio) - (navSize / 2);

    // Limited movement of the navigator
    if (posX > limitX) posX = limitX;

    if (posX < 0) posX = 0;

    if (posY > limitY) posY = limitY;

    if (posY < 0) posY = 0;

    return Offset(posX, posY);
  }

  // Calculate direction between current point and target point
  // Then return the angle in degrees
  double navigatorAngle() {
    // LatLngBounds bounds = rotateLatLngBounds();

    final double lat1 = degToRadian(bounds.center.latitude);
    final double lng1 = degToRadian(bounds.center.longitude);
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

  // Rotates a given LatLngBounds by a specified angle
  LatLngBounds rotateLatLngBounds() {
    LatLng center = LatLng(
      (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
      (bounds.southWest.longitude + bounds.northEast.longitude) / 2,
    );

    LatLng southwest = rotateLatLng(bounds.southWest, center, angle);
    LatLng northeast = rotateLatLng(bounds.northEast, center, angle);

    return LatLngBounds(northeast, southwest);
  }

  // Rotates a LatLng point around a center point by a specified angle
  LatLng rotateLatLng(LatLng point, LatLng center, double angle) {
    double radians = angle * (3.141592653589793238 / 180.0);

    double cosTheta = cos(radians);
    double sinTheta = sin(radians);

    double x = (point.longitude - center.longitude) * cosTheta -
        (point.latitude - center.latitude) * sinTheta +
        center.longitude;
    double y = (point.longitude - center.longitude) * sinTheta +
        (point.latitude - center.latitude) * cosTheta +
        center.latitude;

    return LatLng(y, x);
  }
}
