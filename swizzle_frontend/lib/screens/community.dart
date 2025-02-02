import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:swizzle_frontend/screens/createCommunity.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteCommunity(String docId, String creatorId) async {
    if (user?.uid != creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You can only delete communities you created')),
      );
      return;
    }

    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Community'),
            content:
                const Text('Are you sure you want to delete this community?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await _firestore
                      .collection('communities')
                      .doc(docId)
                      .delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Community deleted successfully')),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting community: $e')),
      );
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('communities');

    if (_searchText.isNotEmpty) {
      query =
          query.where('placeLowercase', isEqualTo: _searchText.toLowerCase());
    }

    return query;
  }

  void _performSearch() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple, // Modern color
        elevation: 4, // Adds shadow for depth
        shadowColor: Colors.deepPurple.withOpacity(0.5), // Shadow color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom edges
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // White back arrow
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCommunityPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.white),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by place or name',
                      hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: _performSearch,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.black)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final communities = snapshot.data?.docs ?? [];

                if (communities.isEmpty) {
                  return const Center(
                    child: Text('No communities found',
                        style: TextStyle(color: Colors.black)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    final doc = communities[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isCreator = data['createdBy'] == user?.uid;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(data['name'] ?? '',
                            style: TextStyle(color: Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['description'] ?? '',
                                style: TextStyle(color: Colors.black)),
                            Text('Place: ${data['place']}',
                                style: TextStyle(color: Colors.black)),
                            SelectableText('Room ID: ${data['roomId']}',
                                style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 8), // Add some spacing
                            // Copy button
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                // Copy the text to the clipboard
                                Clipboard.setData(ClipboardData(text: data['roomId']));
                                // Show a SnackBar to confirm the copy action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Copied to clipboard!')),
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: isCreator
                            ? IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteCommunity(doc.id, data['createdBy']),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
