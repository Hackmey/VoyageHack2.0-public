import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/gmapscreen.dart';

class ProfilesScreen extends StatelessWidget {
  final String type;

  ProfilesScreen({super.key, required this.type});

  // Dummy profiles for demonstration
  final List<Map<String, dynamic>> profiles = [
    {
      "name": "John Doe",
      "type": "Local Guide",
      "location": {"lat": 19.2277, "lng": 82.5491},
      "status": "Available"
    },
    {
      "name": "Jane Smith",
      "type": "Couch Surfer",
      "location": {"lat": 37.7849, "lng": -122.4294},
      "status": "Not Available"
    },
    {
      "name": "Music Festival",
      "type": "Event",
      "location": {"lat": 37.7649, "lng": -122.4094},
      "status": "Ongoing"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type),
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(profile['name']),
            subtitle: Text('Status: ${profile['status']}'),
            trailing: TextButton(
              child: Text('Show on Map'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsScreen(
                      title: profile['name'],
                      location: profile['location'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
