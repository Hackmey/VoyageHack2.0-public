import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swizzle_frontend/screens/localGuideProfile.dart';

class LocalGuideScreen extends StatefulWidget {
  const LocalGuideScreen({super.key});




  @override
  _LocalGuideScreenState createState() => _LocalGuideScreenState();
}

class _LocalGuideScreenState extends State<LocalGuideScreen> {
  // Dummy data for local guides with latitude and longitude
  final List<Map<String, dynamic>> localGuides = [
    {
      "id": "1",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phone": "+1234567890",
      "rating": 4.8,
      "language": "English",
      "latitude": 19.2277,
      "longitude": 82.5491, // New York
      "available": true,
      "dp": "https://via.placeholder.com/150"
    },
    {
      "id": "2",
      "name": "Maria Smith",
      "email": "maria.smith@example.com",
      "phone": "+9876543210",
      "rating": 4.5,
      "language": "Spanish",
      "latitude": 34.0522,
      "longitude": -118.2437, // Los Angeles
      "available": true,
      "dp": "https://via.placeholder.com/150"
    }
  ];

  String? selectedLanguage;
  double maxDistance = 10.0;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    // Get user's current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userPosition = position;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to kilometers
  }

  Future<void> _saveBooking(Map<String, dynamic> guide) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(guide.toString());
    prefs.setString("bookedGuide", guide.toString());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LocalGuideProfile(guide: guide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Local Guide'),
      ),
      body: userPosition == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    hint: Text("Preferred Language"),
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                    items: ["English", "Spanish", "Japanese"]
                        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text("Maximum Distance (km): ${maxDistance.toStringAsFixed(1)}"),
                  Slider(
                    value: maxDistance,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: maxDistance.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        maxDistance = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Text("Find Guides"),
                      onPressed: () {
                        List<Map<String, dynamic>> filteredGuides = localGuides.where((guide) {
                          double distance = _calculateDistance(
                            userPosition!.latitude,
                            userPosition!.longitude,
                            guide['latitude'],
                            guide['longitude'],
                          );
                          return distance <= maxDistance &&
                              (selectedLanguage == null || guide['language'] == selectedLanguage) &&
                              guide['available'] == true;
                        }).toList();

                        if (filteredGuides.isNotEmpty) {
                          filteredGuides.sort((a, b) => b['rating'].compareTo(a['rating']));
                          Map<String, dynamic> topGuide = filteredGuides.first;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Top Guide Found"),
                                content: Text(
                                    "Name: ${topGuide['name']}\nRating: ${topGuide['rating']}\nLanguage: ${topGuide['language']}\nDistance: ${_calculateDistance(userPosition!.latitude, userPosition!.longitude, topGuide['latitude'], topGuide['longitude']).toStringAsFixed(2)} km"),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text("Book"),
                                    onPressed: () async {
                                      await _saveBooking(topGuide);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Guide ${topGuide['name']} booked!")),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No guides found matching your criteria.")),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
