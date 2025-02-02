import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatScreen extends StatefulWidget {
  final String roomCode;
  final String groupName;
  const GroupChatScreen(
      {super.key, required this.roomCode, required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('groups');

  User? _user; // Firebase Auth user object
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
    addGroup(widget.roomCode);
  }

  // Add a group to the user's 'groups' map
  Future<void> addGroup(String groupCode) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(_user!.uid);

    try {
      await userDocRef.update({
        'groups': FieldValue.arrayUnion(
            [groupCode]), // Use arrayUnion or set a unique group as a map key
      });
      print('Group added to user successfully.');
    } catch (e) {
      print('Error adding group: $e');
    }
  }

  // Fetch the logged-in user data
  Future<void> _fetchLoggedInUser() async {
    _user = FirebaseAuth.instance.currentUser;
    // Use displayName or email as username
    if (_user != null) {
      try {
        // Fetch the user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          // Extract the fullName field, fallback to email if fullName doesn't exist
          setState(() {
            _username =
                userDoc.data()?['fullName'] ?? _user!.email ?? "Unknown User";
          });
        } else {
          setState(() {
            _username = _user!.email ?? "Unknown User";
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          _username = _user!.email ?? "Unknown User";
        });
      }
    }
  }

  // Send a message to the current room
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && _username != null) {
      _roomsCollection.doc(widget.roomCode).collection('messages').add({
        'text': message,
        'sender': _username,
        'createdAt': Timestamp.now(),
      });
      _messageController.clear();
    }
  }

  // Chat room UI
  Widget _buildChatRoom() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Code: ${widget.roomCode}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _roomsCollection
                .doc(widget.roomCode)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data?.docs ?? [];

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final sender = message['sender'] ?? 'Unknown';
                  final text = message['text'] ?? '';
                  final timestamp = message['createdAt'].toDate();
                  final isMe = sender == _username;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0),
                      padding: const EdgeInsets.all(10.0),
                      constraints: const BoxConstraints(
                        minWidth: 80.0,
                        maxWidth: 250.0,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.teal : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sender,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Text(
                              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 8,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.teal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
        backgroundColor: Colors.teal,
      ),
      body: _buildChatRoom(),
    );
  }
}
