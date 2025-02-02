import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  final String title;
  final Map<String, double> location;

  const MapsScreen({super.key, required this.title, required this.location});

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.location['latitude']!, widget.location['longitude']!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 7.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
            infoWindow: InfoWindow(title: widget.title),
          ),
        },
      ),
    );
  }
}
