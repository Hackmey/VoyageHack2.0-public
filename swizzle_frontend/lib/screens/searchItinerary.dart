import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/itineraryDetails.dart';




class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> itineraries = [];
  TextEditingController searchController = TextEditingController();

  void fetchItineraries(String query) async {
    if (query.isEmpty) return; // Avoid searching with an empty query

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('itineraries')
        .where('place', isGreaterThanOrEqualTo: query)
        .where('place', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    print("Query result: ${snapshot.docs.length} documents found.");

    setState(() {
      itineraries = snapshot.docs.map((doc) {
        print("Itinery data ${doc.data()}");
        return {
          'place': doc['place'] ?? '',
          'description': doc['description'] ?? '',
          'days': doc['days'] ?? '',
          'nights': doc['nights'] ?? '',
          'upvotes': doc['upvotes'] ?? 0,
          'id': doc['id'] ?? '',
        };
      }).toList();
    });
    print(itineraries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Itinerary'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              fetchItineraries(searchController.text);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Search Itinerary',
                  labelStyle:
                      TextStyle(color: Colors.black), // Black label text
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: itineraries.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: itineraries.length,
                      itemBuilder: (context, index) {
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
                            margin: EdgeInsets.symmetric(vertical: 8),
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
                                Text(
                                  itineraries[index]['place'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Days: ${itineraries[index]['days']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Nights: ${itineraries[index]['nights']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.thumb_up, size: 18),
                                        SizedBox(width: 4),
                                        Text(
                                          '${itineraries[index]['upvotes']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
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
        ),
      ),
    );
  }
}
