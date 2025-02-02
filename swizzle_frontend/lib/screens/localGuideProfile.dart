// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/gmapscreen.dart';

class LocalGuideProfile extends StatelessWidget {
  final Map<String, dynamic> guide;


    LocalGuideProfile({super.key, required this.guide}) {
      if (kDebugMode) {
        print("Guide Object: $guide");
      }
    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide['name'] ?? 'Guide Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(guide['dp'] ?? ''),
            ),
            SizedBox(height: 20),
            Text("Name: ${guide['name'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Email: ${guide['email'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Phone: ${guide['phone'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Rating: ${guide['rating'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (guide.containsKey('latitude') && guide.containsKey('longitude')) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>MapsScreen(title: guide['name'], location: {'latitude': guide['latitude'], 'longitude': guide['longitude']}),
                    ),
                  );
                } 
                else {
                  SnackBar(content: Text('Location data is not available for this guide.'));
                }
                 



              },
              child: Text("Show on Map"),
            ),
          ],
        ),
      ),
    );
  }
}
