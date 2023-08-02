import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:nav_marker/map_or_nav_marker.dart';
import 'package:nav_marker/src/arrow_painter.dart';
import 'package:nav_marker/src/controller.dart';

class NavigationOverlay extends StatelessWidget {
  const NavigationOverlay({
    Key? key,
    required this.mapState,
    required this.mapOrNavMarkers,
  }) : super(key: key);

  final FlutterMapState mapState;
  final List<MapOrNavMarker> mapOrNavMarkers;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mapState.mapController.mapEventStream,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const SizedBox.shrink();
        }

        return Transform.rotate(
          /// counter rotating the box drawn on screen
          angle: -mapState.rotationRad,

          /// ! this actualy does something
          child: Center(
            child: SizedBox.fromSize(
              size: mapState.boxSize!,
              child: MapOrNavMarkers(
                mapOrNavMarkers: mapOrNavMarkers,
                mapState: mapState,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MapOrNavMarkers extends StatelessWidget {
  const MapOrNavMarkers({
    super.key,
    required this.mapOrNavMarkers,
    required this.mapState,
  });

  final List<MapOrNavMarker> mapOrNavMarkers;
  final FlutterMapState mapState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        mapOrNavMarkers.length,
        (index) {
          /// all the variables used to generate this marker on screen
          MapOrNavMarker mapOrNavMarker = mapOrNavMarkers[index];
          NavMarkerSettings navMarkerOptions =
              mapOrNavMarker.navMarkerSettings ?? const NavMarkerSettings();
          return NavMarkerWidget(
            ctrl: NavMarkerCtrl(
              mapState: mapState,
              mapOrNavMarker: mapOrNavMarker,
              navMarkerOptions: navMarkerOptions,
            ),
          );
        },
      ),
    );
  }
}

class NavMarkerBaseAndArrow extends StatelessWidget {
  const NavMarkerBaseAndArrow({
    super.key,
    required this.angle,
    required this.navMarkerCtrl,
  });

  final double angle;
  final NavMarkerCtrl navMarkerCtrl;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      origin: Offset(
        navMarkerCtrl.navMarkerOptions.size / 2,
        navMarkerCtrl.navMarkerOptions.size / 2,
      ),
      child: CustomPaint(
        painter: ArrowPainter(
          size: navMarkerCtrl.navMarkerOptions.size,
          color: navMarkerCtrl.navMarkerOptions.arrowColor,
        ),
      ),
    );
  }
}

class NavMarkerTappableBody extends StatelessWidget {
  const NavMarkerTappableBody({
    super.key,
    required this.navMarkerCtrl,
  });

  final NavMarkerCtrl navMarkerCtrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => navMarkerCtrl.navMarkerOptions.onTap != null
            ? navMarkerCtrl
                .navMarkerOptions.onTap!(navMarkerCtrl.mapOrNavMarker.point)
            : null,

        /// Set navigator's body
        /// If [image] or [child] is not set, will be based on marker builder
        child: navMarkerCtrl.navMarkerOptions.image != null
            ? CircleAvatar(
                backgroundColor: navMarkerCtrl.navMarkerOptions.backgroundColor,
                radius: navMarkerCtrl.navMarkerOptions.size / 3,
                child: CircleAvatar(
                  radius: navMarkerCtrl.navMarkerOptions.size / 3.5,
                  backgroundImage: navMarkerCtrl.navMarkerOptions.image,
                ),
              )
            : navMarkerCtrl.navMarkerOptions.child != null
                ? navMarkerCtrl.navMarkerOptions.child!
                : CircleAvatar(
                    backgroundColor:
                        navMarkerCtrl.navMarkerOptions.backgroundColor,
                    radius: navMarkerCtrl.navMarkerOptions.size / 3,
                    child: CircleAvatar(
                      radius: navMarkerCtrl.navMarkerOptions.size / 3.5,
                      backgroundColor:
                          navMarkerCtrl.navMarkerOptions.surfaceColor,
                      child: navMarkerCtrl.mapOrNavMarker.builder(context),
                    ),
                  ),
      ),
    );
  }
}

///
///
///
///
///
///
///
///
///
///
/// POSITION AND ROTATION STUFF
///
///
///
///
///
///
///
///
///
///

class NavMarkerWidget extends StatelessWidget {
  const NavMarkerWidget({
    super.key,
    required this.ctrl,
  });

  final NavMarkerCtrl ctrl;

  @override
  Widget build(BuildContext context) {
    if (ctrl.navMarkerIsEnabled && ctrl.mapMarkerIsOutOfBounds) {
      Offset navMarkerPosition = ctrl.navMarkerPosition;
      return Positioned(
        top: navMarkerPosition.dy,
        left: navMarkerPosition.dx,
        child: SizedBox(
          width: ctrl.navMarkerOptions.size,
          height: ctrl.navMarkerOptions.size,
          child: Stack(
            children: [
              NavMarkerBaseAndArrow(
                angle: ctrl.headingInRadians(navMarkerPosition) + ctrl.angle,
                navMarkerCtrl: ctrl,
              ),
              NavMarkerTappableBody(navMarkerCtrl: ctrl),
            ],
          ),
        ),
      );
    }

    /// return nothing
    return const SizedBox.shrink();
  }
}
