import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:swizzle_frontend/screens/itineraryDetails.dart';
import 'package:swizzle_frontend/screens/trendingItineraries.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Text('Search Itinerary'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateItineraryPage()),
                    );
                  },
                  child: Text('Post Itinerary'),
                ),
                SizedBox(height: 20),
                TrendingItineraries(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                                SizedBox(height: 6),
                                Text(
                                  itineraries[index]['description'],
                                  style: TextStyle(
                                    fontSize: 14,
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

class CreateItineraryPage extends StatefulWidget {
  const CreateItineraryPage({super.key});

  @override
  _CreateItineraryPageState createState() => _CreateItineraryPageState();
}

class _CreateItineraryPageState extends State<CreateItineraryPage> {
  TextEditingController placeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  TextEditingController nightsController = TextEditingController();

  void saveItinerary() async {
    if (placeController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('itineraries').add({
        'place': placeController.text,
        'description': descriptionController.text,
        'days': daysController.text,
        'nights': nightsController.text,
        'upvotes': 0,
      });

      String itineraryId = docRef.id;
      print('Itinerary saved with ID: $itineraryId');

      // Optionally, you can also update other fields using the document ID
      await docRef.update({
        'id': itineraryId, // Store the unique ID if needed
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Itinerary'),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: placeController,
              decoration: InputDecoration(
                labelText: 'Enter Place',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              maxLines: null, // Allows multiple lines
              keyboardType:
                  TextInputType.multiline, 
              textInputAction: TextInputAction.newline,// Enables Enter key for new lines
            ),
            SizedBox(height: 10),
            TextField(
              controller: daysController,
              decoration: InputDecoration(
                labelText: 'Enter Days',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            TextField(
              controller: nightsController,
              decoration: InputDecoration(
                labelText: 'Enter Nights',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: saveItinerary,
              child: Text('Post Itinerary'),
            ),
          ],
        ),
      ),
    );
  }
}

// class ItineraryDetailsPage extends StatefulWidget {
//   final String itineraryId;

//   const ItineraryDetailsPage({super.key, required this.itineraryId});

//   @override
//   _ItineraryDetailsPageState createState() => _ItineraryDetailsPageState();
// }

// class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
//   String place = '';
//   String description = '';
//   String days = '';
//   String nights = '';
//   int upvotes = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchItineraryDetails();
//   }

//   // Fetch itinerary details using unique itineraryId
//   void _fetchItineraryDetails() async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('itineraries')
//         .doc(widget.itineraryId)
//         .get();

//     if (snapshot.exists) {
//       setState(() {
//         place = snapshot['place'] ?? 'No place'; // Default 'No place' if null
//         description = snapshot['description'] ??
//             'No description'; // Default 'No description' if null
//         days = snapshot['days'] ?? '0'; // Default '0' if null
//         nights = snapshot['nights'] ?? '0'; // Default '0' if null
//         upvotes = snapshot['upvotes'] ?? 0; // Default 0 if null
//       });
//     } else {
//       // Handle the case if the document doesn't exist
//       setState(() {
//         place = 'No place available';
//         description = 'No description available';
//         days = '0';
//         nights = '0';
//         upvotes = 0;
//       });
//     }
//   }

//   // Increment upvotes and update Firestore
//   void _increaseUpvote() async {
//     setState(() {
//       upvotes++;
//     });

//     await FirebaseFirestore.instance
//         .collection('itineraries')
//         .doc(widget.itineraryId)
//         .update({
//       'upvotes': upvotes,
//     });
//   }

//   // Copy itinerary details to clipboard
//   void _copyToClipboard() {
//     String itineraryDetails = """
// Place: $place
// Description: $description
// Days: $days
// Nights: $nights
// Upvotes: $upvotes
// """;

//     Clipboard.setData(ClipboardData(text: itineraryDetails)).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Itinerary copied to clipboard!"),
//         duration: Duration(seconds: 2),
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Itinerary Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     place,
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '🌞',
//                                   style: TextStyle(fontSize: 24),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   '$days Days',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '🌙',
//                                   style: TextStyle(fontSize: 24),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   '$nights Nights',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 24),
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '⭐ ',
//                             style: TextStyle(fontSize: 24),
//                           ),
//                           Text(
//                             '$upvotes Upvotes',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _increaseUpvote,
//                       icon: Icon(Icons.thumb_up, color: Colors.white),
//                       label: Text('Upvote this Itinerary'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 16),
//                         textStyle: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton.icon(
//                       onPressed: _copyToClipboard,
//                       icon: Icon(Icons.copy, color: Colors.white),
//                       label: Text('Copy Itinerary'),
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         side: BorderSide(color: Colors.black, width: 1.5),
//                         padding: EdgeInsets.symmetric(vertical: 16),
//                         textStyle: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class TrendingItineraries extends StatefulWidget {
//   @override
//   _TrendingItinerariesState createState() => _TrendingItinerariesState();
// }

// class _TrendingItinerariesState extends State<TrendingItineraries> {
//   final PageController _pageController = PageController(viewportFraction: 0.85);
//   List<Map<String, dynamic>> itineraries = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchTrendingItineraries();
//   }

//   void fetchTrendingItineraries() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('itineraries')
//         .orderBy('upvotes', descending: true)
//         .limit(5)
//         .get();

//     setState(() {
//       itineraries = snapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               Text(
//                 '🔥 ',
//                 style: TextStyle(fontSize: 24),
//               ),
//               Text(
//                 'Trending Itineraries',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 200,
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: itineraries.length,
//             itemBuilder: (context, index) {
//               final itinerary = itineraries[index];
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ItineraryDetailsPage(
//                           itineraryId: itineraries[index]['id']),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 8),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.black, width: 1),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         spreadRadius: 1,
//                         blurRadius: 5,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         itinerary['place'],
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         " 🌞${itinerary['days']} days",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         "🌛 ${itinerary['nights']} nights",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Text(
//                             '⭐ ',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           Text(
//                             '${itinerary['upvotes']} upvotes',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
