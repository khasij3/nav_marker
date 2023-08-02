import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:nav_marker/nav_marker.dart';

extension FlutterMapStateExtension on FlutterMapState {
  RenderBox get renderBox => context.findRenderObject() as RenderBox;
  Size? get boxSize => renderBox.hasSize ? renderBox.size : null;
  Offset? get boxPos =>
      renderBox.hasSize ? renderBox.globalToLocal(Offset.zero) : null;

  // This will convert a latLng to a position that we could use with a widget
  // outside of FlutterMap layer space. Eg using a Positioned Widget.
  LatLng screenPointToLatLng(CustomPoint<double> screenPoint) {
    CustomPoint<int> nonRotatedPixelOrigin =
        (project(center, zoom) - nonrotatedSize / 2.0).round();
    final mapCenter = options.crs.latLngToPoint(center, zoom);

    /// screenPoint = point - nonRotatedPixelOrigin
    CustomPoint<double> point = screenPoint + nonRotatedPixelOrigin;

    /// undo rotation
    if (rotation != 0.0) {
      point = rotatePoint(mapCenter, point, counterRotation: true);
    }

    /// convert back to lat lng
    return options.crs.pointToLatLng(point, zoom);
  }
}

class NavMarkerCtrl {
  NavMarkerCtrl({
    required this.mapState,
    required this.mapOrNavMarker,
    required this.navMarkerOptions,
  });

  /// the basics bits of data we need for the math below
  final FlutterMapState mapState;
  final NavMarker mapOrNavMarker;
  final NavigatorOptions navMarkerOptions;

  /// [mapState] getters
  Size get size => mapState.boxSize!;
  double get angle => mapState.rotationRad;
  LatLngBounds get bounds => mapState.mapController.bounds!;

  /// [mapOrNavMarker] getters
  LatLng get targetPoint => mapOrNavMarker.point;
  double get navSize => navMarkerOptions.size;

  bool get navMarkerIsEnabled => mapOrNavMarker.navigator == true;
  bool get mapMarkerIsOutOfBounds => containsMarker() == false;

  /// doesn't care about point size
  /// TODO: might wanna care about size but then might also need extra math size sometimes marker height and width don't match and marker may or may not rotate
  bool containsMarker() {
    CustomPoint<double> converted =
        mapState.latLngToScreenPoint(mapOrNavMarker.point);

    /// x gets negative on left side to side
    /// y get negative on top up and down
    if (converted.x < 0) return false;
    if (converted.y < 0) return false;
    if (converted.x > size.width) return false;
    if (converted.y > size.height) return false;
    return true;
  }

  // Calculate position of the navigator on screen
  Offset get navMarkerPosition {
    CustomPoint converted = mapState.latLngToScreenPoint(mapOrNavMarker.point);

    /// Calculate horizontal and vertical ratio
    final double horizontalRatio = (size.width - converted.x) / (size.width);
    final double verticalRatio = (size.height - converted.y) / (size.height);

    /// use the ratio to figure out the position of the target
    /// - the position is always on the edge if unbound
    double posX = (size.width * horizontalRatio) - (navSize / 2);
    double posY = (size.height * verticalRatio) - (navSize / 2);

    /// the boundary of the screen
    /// minus the size of the marker
    ///
    /// I.O.W. the boundaries of the center of the marker
    double xAxisLimit = size.width - navSize;
    double yAxisLimit = size.height - navSize;

    /// make sure the calculated location is within that boundary
    if (posX > xAxisLimit) posX = xAxisLimit;
    if (posX < 0) posX = 0;
    if (posY > yAxisLimit) posY = yAxisLimit;
    if (posY < 0) posY = 0;

    /// calc this in a way that it is reusable
    Offset finalOffset = Offset(
      size.width - posX - navSize,
      size.height - posY - navSize,
    );

    /// ship the boundary
    return finalOffset;
  }

  // Calculate direction between current point and target point
  // Then return the angle in degrees
  double headingInRadians(Offset navMarkerScreenPoint) {
    CustomPoint<double> navMarkerCustomPoint = CustomPoint(
      navMarkerScreenPoint.dx + (navSize / 2),
      navMarkerScreenPoint.dy + (navSize / 2),
    );
    LatLng navMarkerLatLng = mapState.screenPointToLatLng(navMarkerCustomPoint);

    /// cal the stuffs
    final double lat1 = degToRadian(navMarkerLatLng.latitude);
    final double lng1 = degToRadian(navMarkerLatLng.longitude);
    final double lat2 = degToRadian(targetPoint.latitude);
    final double lng2 = degToRadian(targetPoint.longitude);

    // Calculate difference in longitude
    final double dLng = lng2 - lng1;

    // Calculate [x] and [y] coordinates
    // Then calculate angle from [x] and [y]
    final double y = math.sin(dLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final double angle = math.atan2(y, x);

    // Convert angle back to degrees
    // And normalize the angle within 0 to 360
    double angleInDegrees = radianToDeg(angle);
    angleInDegrees = angleInDegrees % 360;

    return degToRadian(angleInDegrees);
  }
}
