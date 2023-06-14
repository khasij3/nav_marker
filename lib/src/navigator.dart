import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:nav_marker/nav_marker.dart';
import 'package:nav_marker/src/arrow_painter.dart';
import 'package:nav_marker/src/layout.dart';

class NavigatorStream {
  NavigatorStream({
    required this.size,
    required this.angle,
    required this.position,
    required this.center,
    required this.bounds,
  });
  final Size size;
  final double angle;
  final Offset position;
  final LatLng center;
  final LatLngBounds bounds;
}

class Navigator extends StatelessWidget {
  const Navigator({
    Key? key,
    required this.map,
    required this.markers,
  }) : super(key: key);

  final FlutterMapState map;
  final List<NavMarker> markers;

  @override
  Widget build(BuildContext context) {
    final navigatorCtrl = StreamController<NavigatorStream>();

    Size? boxSize;
    Offset? boxPos;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Set [boxSize] after parent context has size
      final renderBox = map.context.findRenderObject() as RenderBox;
      if (renderBox.hasSize) {
        boxSize = renderBox.size;
        boxPos = renderBox.globalToLocal(Offset.zero);

        // Initial navigator stream as [NavigatorStream]
        // Which [MapEvent] is not trigger yet
        navigatorCtrl.add(NavigatorStream(
          size: boxSize!,
          angle: map.rotationRad,
          position: boxPos!,
          center: map.mapController.center,
          bounds: map.mapController.bounds!,
        ));
        return;
      }
    });

    /// Update navigator stream when [MapEvent] triggered
    map.mapController.mapEventStream.listen((event) {
      navigatorCtrl.add(NavigatorStream(
        size: boxSize!,
        angle: map.rotationRad,
        position: boxPos!,
        center: map.mapController.center,
        bounds: map.mapController.bounds!,
      ));
    });

    return StreamBuilder(
      stream: navigatorCtrl.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return Transform.rotate(
            angle: -data.angle,
            child: Center(
              child: SizedBox(
                width: data.size.width,
                height: data.size.height,
                child: Stack(
                    children: markers.map((marker) {
                  final navigator =
                      marker.navOptions ?? const NavigatorOptions();

                  final layout = NavigatorLayout(
                    bounds: data.bounds,
                    angle: -data.angle,
                    boxPos: data.position,
                    boxSize: data.size,
                    navSize: navigator.size,
                    targetPoint: marker.point,
                  );

                  /// Is true when current bounds find the target position
                  /// And is false when not found
                  bool targetFound = data.bounds.contains(marker.point);

                  Widget navBody = Center(
                    child: GestureDetector(
                      onTap: () => navigator.onTap != null
                          ? navigator.onTap!(marker.point)
                          : null,

                      /// Set navigator's body
                      /// If [image] or [child] is not set, will be based on marker builder
                      child: navigator.image != null
                          ? CircleAvatar(
                              backgroundColor: navigator.backgroundColor,
                              radius: navigator.size / 3,
                              child: CircleAvatar(
                                radius: navigator.size / 3.5,
                                backgroundImage: navigator.image,
                              ),
                            )
                          : navigator.child != null
                              ? navigator.child!
                              : CircleAvatar(
                                  backgroundColor: navigator.backgroundColor,
                                  radius: navigator.size / 3,
                                  child: CircleAvatar(
                                    radius: navigator.size / 3.5,
                                    backgroundColor: navigator.surfaceColor,
                                    child: marker.builder(context),
                                  ),
                                ),
                    ),
                  );

                  /// Set navigator's shape
                  Widget navBase = Transform.rotate(
                    angle: layout.navigatorAngle(),
                    origin: Offset(
                      navigator.size / 2,
                      navigator.size / 2,
                    ),
                    child: CustomPaint(
                      painter: ArrowPainter(
                        size: navigator.size,
                        color: navigator.arrowColor,
                      ),
                    ),
                  );

                  /// Display the navigator while target point out of bounds
                  if (!targetFound && marker.navigator == true) {
                    return Positioned(
                      top: layout.navigatorPosition().dy,
                      left: layout.navigatorPosition().dx,
                      child: SizedBox(
                        width: navigator.size,
                        height: navigator.size,
                        child: Stack(
                          children: [navBase, navBody],
                        ),
                      ),
                    );
                  } else {
                    return Positioned(
                      top: layout.navigatorPosition().dy,
                      left: layout.navigatorPosition().dx,
                      child: const SizedBox(),
                    );
                  }
                }).toList()),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
