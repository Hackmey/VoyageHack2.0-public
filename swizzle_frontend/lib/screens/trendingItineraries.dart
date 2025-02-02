import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:swizzle_frontend/screens/itineraryDetails.dart';

class TrendingItineraries extends StatefulWidget {
  @override
  _TrendingItinerariesState createState() => _TrendingItinerariesState();
}

class _TrendingItinerariesState extends State<TrendingItineraries> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  List<Map<String, dynamic>> itineraries = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingItineraries();
  }

  void fetchTrendingItineraries() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('itineraries')
        .orderBy('upvotes', descending: true)
        .limit(5)
        .get();

    setState(() {
      itineraries = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                '🔥 ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Trending Itineraries',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = itineraries[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItineraryDetailsPage(
                          itineraryId: itineraries[index]['id']),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            12), // Rounded corners for the image
                        child: Image.network(
                          "https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg", // Replace with your image URL or use AssetImage for local images
                          height: 150, // Set the height of the image
                          width: double
                              .infinity, // Make the image take the full width
                          fit: BoxFit.cover, // Ensure the image covers the area
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        itinerary['place'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        " 🌞${itinerary['days']} days",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "🌛 ${itinerary['nights']} nights",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '⭐ ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${itinerary['upvotes']} upvotes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
