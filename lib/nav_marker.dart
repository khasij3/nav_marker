library nav_marker;

import 'package:flutter/material.dart' hide Navigator;
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:nav_marker/src/navigator.dart';
import 'package:nav_marker/src/options.dart';

export 'package:nav_marker/src/options.dart';

class MapOrNavMarker extends Marker {
  MapOrNavMarker({
    this.navMarkerEnabled = false,
    this.navMarkerSettings,
    required Widget Function(BuildContext) builder,
    required LatLng point,
    double width = 30.0,
    double height = 30.0,
    AnchorPos? anchorPos,
    bool? rotate,
    Offset? rotateOrigin,
    AlignmentGeometry? rotateAlignment,
  }) : super(
          point: point,
          builder: builder,
          width: width,
          height: height,
          anchorPos: anchorPos,
          rotate: rotate,
          rotateOrigin: rotateOrigin,
          rotateAlignment: rotateAlignment,
        );

  /// Set [true] to enable navigator of marker
  /// Display the [NavigationOverlay] pointing towards the target position
  final bool navMarkerEnabled;

  /// To customize the style and display format of the [NavigationOverlay]
  final NavMarkerSettings? navMarkerSettings;
}

class MapOrNavMarkerLayer extends MarkerLayer {
  const MapOrNavMarkerLayer({
    Key? key,
    this.mapOrNavMarkers = const [],
    AnchorPos? anchorPos,
    bool rotate = false,
    Offset? rotateOrigin,
    AlignmentGeometry? rotateAlignment = Alignment.center,
  }) : super(
          key: key,
          anchorPos: anchorPos,
          rotate: rotate,
          rotateOrigin: rotateOrigin,
          rotateAlignment: rotateAlignment,
        );

  /// Add markers as [MapOrNavMarker] is a marker that contains a navigator
  final List<MapOrNavMarker> mapOrNavMarkers;

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.of(context);
    final markerWidgets = <Widget>[];

    // Set the marker widget
    for (final marker in mapOrNavMarkers) {
      final pxPoint = map.project(marker.point);

      // See if any portion of the Marker rect resides in the map bounds
      // If not, don't spend any resources on build function.
      // This calculation works for any Anchor position whithin the Marker
      // Note that Anchor coordinates of (0,0) are at bottom-right of the Marker
      // unlike the map coordinates.
      final anchor = Anchor.fromPos(
        marker.anchorPos ?? anchorPos ?? AnchorPos.align(AnchorAlign.center),
        marker.width,
        marker.height,
      );

      final rightPortion = marker.width - anchor.left;
      final leftPortion = anchor.left;
      final bottomPortion = marker.height - anchor.top;
      final topPortion = anchor.top;

      if (!map.pixelBounds.containsPartialBounds(Bounds(
          CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion),
          CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion)))) {
        continue;
      }

      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? rotateOrigin ?? Offset.zero,
              alignment: marker.rotateAlignment ?? rotateAlignment,
              child: marker.builder(context),
            )
          : marker.builder(context);

      markerWidgets.add(
        Positioned(
          key: marker.key,
          width: marker.width,
          height: marker.height,
          left: pos.x - rightPortion,
          top: pos.y - bottomPortion,
          child: markerWidget,
        ),
      );
    }

    return Stack(
      children: [
        Stack(
          children: markerWidgets,
        ),
        NavigationOverlay(
          mapState: map,
          mapOrNavMarkers: mapOrNavMarkers,
        ),
      ],
    );
  }
}
