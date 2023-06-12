import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nav_marker/nav_marker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NavMarker Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController mapController = MapController();

  final LatLng initialPoint = const LatLng(51.509364, -0.128928);

  final List<LatLng> points = const [
    LatLng(52.519364, -0.148928),
    LatLng(49.239764, 0.168928),
    LatLng(50.509364, 1.358928),
  ];

  final List<Widget> builders = const [
    CircleAvatar(
      backgroundImage: AssetImage('assets/images/man_portrait.jpg'),
    ),
    CircleAvatar(
      backgroundImage: AssetImage('assets/images/woman_portrait.jpg'),
    ),
    Icon(Icons.location_on_sharp)
  ];

  List<NavMarker>? markers;

  @override
  void initState() {
    initMarkers();
    super.initState();
  }

  void initMarkers() {
    for (int i = 0; i < points.length; i++) {
      markers!.add(
        NavMarker(
          navigator: true,
          navOptions: NavigatorOptions(
            onTap: (targetPoint) => mapController.move(
              targetPoint,
              mapController.zoom,
            ),
          ),
          builder: (_) => builders[i],
          point: points[i],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('NavMarker Example'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: initialPoint,
          zoom: 9.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          NavMarkerLayer(navMarkers: markers!.toList()),
        ],
      ),
    );
  }
}
