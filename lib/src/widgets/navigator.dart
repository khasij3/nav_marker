import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:nav_marker/nav_marker.dart';
import 'package:nav_marker/src/drawing/arrow_painter.dart';
import 'package:nav_marker/src/models/navigator_layout.dart';
import 'package:nav_marker/src/models/map_stream.dart';

class Navigator extends StatefulWidget {
  const Navigator({
    super.key,
    required this.map,
    required this.navMarkers,
  });

  final FlutterMapState map;
  final List<NavMarker> navMarkers;

  @override
  State<Navigator> createState() => _NavigatorState();
}

class _NavigatorState extends State<Navigator> {
  final navigatorCtrl = StreamController<MapStream>();

  Size? mapSize;
  Offset? mapPos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Set [mapSize] after parent context has size
      final renderBox = widget.map.context.findRenderObject() as RenderBox;
      if (renderBox.hasSize) {
        mapSize = renderBox.size;
        mapPos = renderBox.globalToLocal(Offset.zero);

        /// Initial navigator stream as [NavStream]
        navigatorCtrl.add(MapStream(
          size: mapSize!,
          position: mapPos!,
          center: widget.map.center,
          bounds: widget.map.bounds,
        ));
        return;
      }
    });

    /// Update navigator stream when [MapEvent] triggered
    widget.map.mapController.mapEventStream.listen((event) {
      navigatorCtrl.add(MapStream(
        size: mapSize ?? Size(0, 0),
        position: mapPos ?? Offset.zero,
        center: event.center,
        bounds: widget.map.bounds,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: navigatorCtrl.stream,
      builder: (context, snapshot) {
        // Display content when a snapshot has data
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return Stack(
              children: widget.navMarkers.map((marker) {
            final navigator = marker.navOptions ?? const NavigatorOptions();

            final layout = NavigatorLayout(
              mapBounds: data.bounds,
              mapPos: data.position,
              mapSize: data.size,
              navSize: navigator.size,
              targetPoint: marker.point,
            );

            // Is true when current bounds find the target position
            // And is false when not found
            bool targetFound = data.bounds.contains(marker.point);

            // Set navigator's body
            // If [image] or [child] is not set, will be based on marker builder
            Widget navBody() {
              if (navigator.image != null) {
                return CircleAvatar(
                  backgroundImage: navigator.image,
                );
              } else if (navigator.child != null) {
                return navigator.child!;
              } else {
                return marker.builder(context);
              }
            }

            // Set navigator's shape
            Widget navShape = CustomPaint(
              painter: ArrowPainter(
                size: navigator.size,
                arrowColor: navigator.arrowColor,
                bodyColor: navigator.backgroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(navigator.size / 5),
                child: Transform.rotate(
                  angle: layout.navAngle() * -1,
                  child: GestureDetector(
                    onTap: () => navigator.onTap != null
                        ? navigator.onTap!(marker.point)
                        : null,
                    child: navBody(),
                  ),
                ),
              ),
            );

            // Display [Navigator] while target point out of current bounds
            if (!targetFound && marker.navigator == true) {
              return Positioned(
                top: layout.navPos().dy,
                left: layout.navPos().dx,
                child: SizedBox(
                  width: navigator.size,
                  height: navigator.size,
                  child: Transform.rotate(
                    angle: layout.navAngle(),
                    child: navShape,
                  ),
                ),
              );
            }
            return const SizedBox();
          }).toList());
        }

        return const SizedBox();
      },
    );
  }
}
