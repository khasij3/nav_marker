import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapStream {
  MapStream({
    required this.size,
    required this.position,
    required this.center,
    required this.bounds,
  });
  final Size size;
  final Offset position;
  final LatLng center;
  final LatLngBounds bounds;
}
