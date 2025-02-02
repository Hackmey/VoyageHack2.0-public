import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ItineraryDetailsPage extends StatefulWidget {
  final String itineraryId;

  const ItineraryDetailsPage({super.key, required this.itineraryId});

  @override
  _ItineraryDetailsPageState createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  String place = '';
  String description = '';
  String days = '';
  String nights = '';
  int upvotes = 0;

  // List of image URLs (replace with your own image URLs)
  final List<String> imageUrls = [
    'https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg',
    'https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg',
    'https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg',
    'https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg',
    'https://assets.serenity.co.uk/58000-58999/58779/1296x864.jpg',

  ];

  // PageController for the PageView
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchItineraryDetails();
  }

  // Fetch itinerary details using unique itineraryId
  void _fetchItineraryDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('itineraries')
        .doc(widget.itineraryId)
        .get();

    if (snapshot.exists) {
      setState(() {
        place = snapshot['place'] ?? 'No place';
        description = snapshot['description'] ?? 'No description';
        days = snapshot['days'] ?? '0';
        nights = snapshot['nights'] ?? '0';
        upvotes = snapshot['upvotes'] ?? 0;
      });
    } else {
      setState(() {
        place = 'No place available';
        description = 'No description available';
        days = '0';
        nights = '0';
        upvotes = 0;
      });
    }
  }

  // Increment upvotes and update Firestore
  void _increaseUpvote() async {
    setState(() {
      upvotes++;
    });

    await FirebaseFirestore.instance
        .collection('itineraries')
        .doc(widget.itineraryId)
        .update({
      'upvotes': upvotes,
    });
  }

  // Copy itinerary details to clipboard
  void _copyToClipboard() {
    String itineraryDetails = """
Place: $place
Description: $description
Days: $days
Nights: $nights
Upvotes: $upvotes
""";

    Clipboard.setData(ClipboardData(text: itineraryDetails)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Itinerary copied to clipboard!"),
        duration: Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinerary Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Add the PageView-based carousel here
            SizedBox(
              height: 200, // Height of the carousel
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '🌞',
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '$days Days',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '🌙',
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '$nights Nights',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '⭐ ',
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            '$upvotes Upvotes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _increaseUpvote,
                      icon: Icon(Icons.thumb_up, color: Colors.white),
                      label: Text('Upvote this Itinerary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: Icon(Icons.copy, color: Colors.white),
                      label: Text('Copy Itinerary'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.black, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}