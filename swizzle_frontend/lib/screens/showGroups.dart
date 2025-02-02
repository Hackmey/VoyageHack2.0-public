import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swizzle_frontend/screens/roomFloatingWidget.dart';

class UserGroupsScreen extends StatefulWidget {
  final String userId; // Pass the user's ID

  const UserGroupsScreen({super.key, required this.userId});

  @override
  State<UserGroupsScreen> createState() => _UserGroupsScreenState();
}

class _UserGroupsScreenState extends State<UserGroupsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> _getUserGroups() {
    return _firestore
        .collection('users')
        .doc(widget.userId)
        .snapshots()
        .map((snapshot) {
      final groups = snapshot.data()?['groups'] as List<dynamic>?;
      if (groups != null) {
        return groups.cast<String>();
      }
      return <String>[]; // Default to empty list if no groups exist
    });
  }

    




  Future<void> removeGroup(String groupCode) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupCode]), // or use a map operation
      });
      print('Group removed from user successfully.');
    } catch (e) {
      print('Error removing group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // StreamBuilder for Groups
          StreamBuilder<List<String>>(
            stream: _getUserGroups(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final groups = snapshot.data ?? [];

              if (groups.isEmpty) {
                return const Center(
                  child: Text('You are not a part of any groups yet.'),
                );
              }

              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final groupId = groups[index];
                  return ListTile(
                    title: Text(
                      groupId,
                        style: const TextStyle(
                          fontSize: 15, // Adjust size as needed
                          fontWeight: FontWeight.bold, // Bold text
                          color: Colors.black, // Black color
                        ),),
                    
                    trailing: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Exit'),
                            content: const Text(
                                'Are you sure you want to leave this group?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Exit'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final userDocRef =
                              _firestore.collection('users').doc(widget.userId);

                          try {
                            await userDocRef.update({
                              'groups': FieldValue.arrayRemove([groupId]),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Successfully exited the group "$groupId".'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to exit the group: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          
          // Floating Action Button
          RoomFloatingWidget()
        ],
        
      ),
    );
  }

  // Other methods like deleteRoom or UI-related functions
}
