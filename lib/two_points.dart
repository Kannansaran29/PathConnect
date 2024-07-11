import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class PlotMap extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String titleMessage;

  PlotMap({

    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude, required this.titleMessage,
  });

  @override
  _PlotMapState createState() => _PlotMapState();
}

class _PlotMapState extends State<PlotMap> with OSMMixinObserver {
  late MapController mapController;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController(
      initPosition: GeoPoint(
        latitude: widget.startLatitude,
        longitude: widget.startLongitude,
      ),
    );
    mapController.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleMessage),
      ),
      body: Stack(
        children: [
     
            OSMFlutter(
              controller: mapController,
              osmOption: OSMOption(
                userTrackingOption: UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: ZoomOption(
                  initZoom: 13,
                  minZoomLevel: 10,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    setState(() {
      isMapReady = isReady;
    });
    if (isReady) {
      // Map is ready, you can perform any additional actions here
      plotRoute();
    }
  }

  Future<void> plotRoute() async {
    RoadInfo roadInfo = await mapController.drawRoad(
      GeoPoint(latitude: widget.startLatitude, longitude: widget.startLongitude),
      GeoPoint(latitude: widget.endLatitude, longitude: widget.endLongitude),
    );
    // Optionally, customize road appearance
    // roadInfo = await mapController.drawRoad(startPoint, endPoint, roadOption: RoadOption(roadColor: Colors.red));
  }

  @override
  void dispose() {
    mapController.removeObserver(this);
    super.dispose();
  }
}
