import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class NavigatorStream {
  NavigatorStream({
    required this.target,
  });

  final LatLng target;
}

class NavigatorController with ChangeNotifier {
  final streamCtrl = StreamController<NavigatorStream>();

  Stream<NavigatorStream> get stream => streamCtrl.stream;

  void initial(MapController mapController, LatLng target) {
    // Initial navigator stream as [NavigatorStream]
    // Which [MapEvent] is not trigger yet
    streamCtrl.add(
      NavigatorStream(
        target: target,
      ),
    );

    // Update navigator stream based on [MapController]
    mapController.mapEventStream.listen((event) {
      streamCtrl.add(
        NavigatorStream(
          target: target,
        ),
      );
    });
  }

  @override
  void dispose() {
    streamCtrl.close();
    super.dispose();
  }
}
