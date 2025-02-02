import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/localguide.dart';
import 'package:swizzle_frontend/screens/vendorprofiles.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Custom Google Maps',
          style: TextStyle(color: Colors.black), // Black app bar text
        ),
        backgroundColor: Colors.white, // White app bar background
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black), // Black icon theme
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildCustomTile(
              context,
              icon: Icons.person,
              title: 'Local Guides',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalGuideScreen(),
                  ),
                );
              },
            ),
            _buildCustomTile(
              context,
              icon: Icons.house,
              title: 'Couch Surfers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilesScreen(type: "Couch Surfers"),
                  ),
                );
              },
            ),
            _buildCustomTile(
              context,
              icon: Icons.event,
              title: 'Cultural Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilesScreen(type: "Cultural Events"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1), // Black border
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black, // Black text
            fontSize: 18, // Increased font size
            fontWeight: FontWeight.w600, // Slightly bold
          ),
        ),
        onTap: onTap,
        tileColor: Colors.white, // White tile background
      ),
    );
  }
}
