# nav_marker

`nav_marker` is a Flutter package that allows you to add navigation markers on `flutter_map`
<!-- and `Google Maps for Flutter`. -->

## Previews
<table>
    <tr>
        <td><img width="200" src= "https://github.com/khasij3/nav_marker/blob/main/previews/anim_preview.gif"></td>
        <td><img width="200" src= "https://github.com/khasij3/nav_marker/blob/main/previews/preview1.jpg"></td>
        <td><img width="200" src= "https://github.com/khasij3/nav_marker/blob/main/previews/preview2.jpg"></td>
    </tr>
</table>


## Features

- Define dynamic markers with the `NavigationOverlay` via the `MapOrNavMarkerLayer`
- Display a navigator that directs users towards the marker position.
- Customize the appearance of the navigator to match the marker.

## Getting started

Before using the `nav_marker` package, make sure you have installed and set up `flutter_map` in your Flutter project. If you haven't done so, please refer to the official [flutter_map documentation](https://docs.fleaflet.dev/getting-started/installation) for installation instructions.

## Usage
Import the necessary packages in your Dart file:
```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nav_marker/map_or_nav_marker.dart';
```
Set up your map view using FlutterMap and specify the initial map options, following the instructions provided in the [flutter_map documentation](https://docs.fleaflet.dev/#demonstration).

Then add the `MapOrNavMarkerLayer` to the `children` property of `FlutterMap`

```dart
FlutterMap(
    options: MapOptions( ... ),
    children: [
        TileLayer( ... ),
        MapOrNavMarkerLayer(
            mapOrNavMarkers: [
                ...
            ]
        ),
    ],
),
```

> Caution: Make sure to place the `MapOrNavMarkerLayer` **below** the `TileLayer`.

Add `MapOrNavMarker`s in `mapOrNavMarkers` property within the `MapOrNavMarkerLayer` like so

```dart
MapOrNavMarkerLayer(
    mapOrNavMarkers: [
        MapOrNavMarker(
            navMarkerEnabled: true,
            builder: (_) => builder,
            point: point,
        ),
        MapOrNavMarker(
            navMarkerEnabled: true,
            builder: (_) => builder,
            point: point,
        ),
    ]
),
```

> Note: The `navMarkerEnabled` property must be true in order for the `MapOrNavMarker` to be displayed, similar to a regular `Marker`.

Furthermore, you can customize the appearance of the Nav Marker by defining the `navMarkerSettings` property including an `onTap` function.

```dart
MapOrNavMarker(
    navMarkerEnabled: true,
    navMarkerSettings: NavMarkerSettings(
        onTap: (targetPoint) => onTap,
        arrowColor: arrowColor,
        backgroundColor: backgroundColor,
        surfaceColor: surfaceColor,
        size: size,
        child: child,
    ),
    builder: (context) => builder,
    point: point,
)
```

## Todo-list
- [ ] Develop a version that supports Google Maps.
- [ ] Develop a version that supports integration with other packages.

## Special Thanks to [Bryan Cancel](https://github.com/b-cancel) for
- Adding support for map rotation in flutter_map.
- Enhancing the precision of the direction arrows.