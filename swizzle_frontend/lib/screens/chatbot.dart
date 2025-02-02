import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiChatUI extends StatefulWidget {
  @override
  _ApiChatUIState createState() => _ApiChatUIState();
}

class _ApiChatUIState extends State<ApiChatUI> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _loadMessages();
  }

  void _loadMessages() async {
    // Load messages from Firestore
    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _messages.clear();
        for (var doc in snapshot.docs) {
          _messages.add({
            'sender': doc['sender'],
            'message': doc['message'],
          });
        }
      });
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({
        'sender': 'You',
        'message': _messageController.text,
      });
    });

    // Save the user's message to Firestore
    await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('chat')
        .add({
      'sender': 'You',
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    try {
      final response = await http.post(
        Uri.parse('https://6b54-2401-4900-7015-24ac-f466-8a99-25e7-f7ae.ngrok-free.app/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Save the API's response to Firestore
        await _firestore
            .collection('users')
            .doc(_currentUser.uid)
            .collection('chat')
            .add({
          'sender': 'API',
          'message': responseData['response'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _messages.add({
            'sender': 'API',
            'message': responseData['response'],
          });
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'API',
            'message': 'Failed to get response from API',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'API',
          'message': 'Error: $e',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8, // Set a maximum height
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // Make the chat messages scrollable
              child: Column(
                children: _messages.map((message) {
                  return ChatBubble(
                    sender: message['sender']!,
                    message: message['message']!,
                    isMe: message['sender'] == 'You',
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              _isLoading
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMe;

  const ChatBubble({
    required this.sender,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}