import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swizzle_frontend/screens/groupchat.dart';

class RoomFloatingWidget extends StatefulWidget {
  const RoomFloatingWidget({super.key});

  @override
  _RoomFloatingWidgetState createState() => _RoomFloatingWidgetState();
}

class _RoomFloatingWidgetState extends State<RoomFloatingWidget> {
  bool _isExpanded = false; // Tracks whether the widget is expanded
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  Future<void> _createRoom(BuildContext context) async {
    if (_groupNameController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final roomCode = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Generate unique room code

    // Save to preferences
    await prefs.setString('roomCode', roomCode);
    await prefs.setString('groupName', _groupNameController.text);

    // Save the group to Firestore
    await FirebaseFirestore.instance.collection('groups').doc(roomCode).set({
      'groupName': _groupNameController.text,
      'roomCode': roomCode,
      // Add other fields you may need, like creator, createdAt, etc.
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Navigate to the chat screen with the roomCode and groupName
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(
          roomCode: roomCode,
          groupName: _groupNameController.text,
        ),
      ),
    );
  }

  Future<void> _joinRoom(BuildContext context) async {
    if (_roomCodeController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final roomCode = _roomCodeController.text;

    // Save to preferences
    await prefs.setString('roomCode', roomCode);

    // Fetch group name from Firestore
    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(roomCode)
        .get();

    if (groupDoc.exists) {
      final groupName = groupDoc['groupName'] ??
          'Unknown Group'; // Fallback to a default if not found

      // Save group name in preferences (optional)
      await prefs.setString('groupName', groupName);

      // Navigate to chat screen with fetched group name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            roomCode: roomCode,
            groupName: groupName,
          ),
        ),
      );
    } else {
      // Handle case when room code does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group not found for the provided room code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded)
          Align(
            alignment: Alignment.bottomRight,
            child: Draggable(
              feedback: _buildExpandedWidget(context),
              childWhenDragging: Container(),
              child: _buildExpandedWidget(context),
            ),
          ),
        if (!_isExpanded)
          Align(
            alignment: Alignment.bottomRight,
            child: Draggable(
              feedback: _buildFloatingIcon(),
              childWhenDragging: Container(),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: _buildFloatingIcon(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingIcon() {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(bottom: 20.0, right: 20.0), // Adjust bottom offset
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildExpandedWidget(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Join or Create Room',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              labelStyle: TextStyle(
                color: Colors.black, // Label text in black
              ),
            ),
            style: const TextStyle(
              color: Colors.black, // Input text in black
            ),
          ),
          ElevatedButton(
            onPressed: () => _createRoom(context),
            child: const Text('Create Room'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _roomCodeController,
            decoration: const InputDecoration(
              labelText: 'Room Code',
              labelStyle: TextStyle(
                color: Colors.black, // Label text in black
              ),
              ),
            style: const TextStyle(
              color: Colors.black, // Input text in black
            ),
          ),
          ElevatedButton(
            onPressed: () => _joinRoom(context),
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }
}
