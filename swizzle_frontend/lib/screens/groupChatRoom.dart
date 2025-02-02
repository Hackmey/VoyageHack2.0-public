import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchJoinedGroups();
  }

  Stream<List<Map<String, dynamic>>> _fetchJoinedGroups() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUser.uid)
        .snapshots()
        .map((groupsSnapshot) => groupsSnapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc['name'],
              };
            }).toList());
  }

  void _showGroupModal() {
    final createController = TextEditingController();
    final joinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: createController,
                decoration: InputDecoration(
                  labelText: 'Create Group',
                  hintText: 'Enter group name',
                ),
              ),
              ElevatedButton(
                onPressed: () => _createGroup(createController.text),
                child: Text('Create Group'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: joinController,
                decoration: InputDecoration(
                  labelText: 'Join Group',
                  hintText: 'Enter group ID',
                ),
              ),
              ElevatedButton(
                onPressed: () => _joinGroup(joinController.text),
                child: Text('Join Group'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createGroup(String groupName) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || groupName.isEmpty) return;

    DocumentReference groupRef = await _firestore.collection('groups').add({
      'name': groupName,
      'members': [currentUser.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatPage(
          groupId: groupRef.id,
          groupName: groupName,
        ),
      ),
    );
  }

  Future<void> _joinGroup(String groupId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || groupId.isEmpty) return;

    try {
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([currentUser.uid])
      });

      DocumentSnapshot groupSnap =
          await _firestore.collection('groups').doc(groupId).get();

      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatPage(
            groupId: groupId,
            groupName: groupSnap['name'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Groups'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchJoinedGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No groups joined yet.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          var groups = snapshot.data!;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Text(
                        group['name'][0].toUpperCase(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      group['name'],
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.black54),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatPage(
                          groupId: group['id'],
                          groupName: group['name'],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGroupModal,
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _apiMessageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _tabController = TabController(length: 2, vsync: this);
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty || _currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(_currentUser!.uid).get();
    String senderName = userDoc['fullName'] ?? 'Unknown';

    _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'text': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'sender': senderName,
      'senderId': _currentUser!.uid,
    });

    _messageController.clear();
  }

  void _sendApiMessage() async {
    if (_apiMessageController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Save the user's message to Firebase immediately
    final userMessageRef = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('apiChat')
        .add({
      'message': _apiMessageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': _currentUser?.uid,
      'sender': (await _firestore.collection('users').doc(_currentUser?.uid).get()).data()?['fullName'] ?? 'Anonymous',
      'type': 'user', // Indicates that this is a user message
    });

    final client = http.Client();
    final response = await client
        .post(
      Uri.parse(
          'https://6b54-2401-4900-7015-24ac-f466-8a99-25e7-f7ae.ngrok-free.app/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': _apiMessageController.text,
      }),
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      throw SocketException('Connection timed out');
    });

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Save the API's response to Firebase
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('apiChat')
          .add({
        'message': responseData['response'],
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': 'api', // Indicates that this is an API response
        'sender': 'API',
        'type': 'api', // Indicates that this is an API message
      });

      _apiMessageController.clear();
    } else {
      // If the API call fails, update the user's message in Firebase to indicate failure
      await userMessageRef.update({
        'status': 'failed',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message to API')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.api), text: 'SwizzleBot'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.poll),
            onPressed: _createPoll,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyGroupId,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chat Tab
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var message = snapshot.data!.docs[index];
                          bool isSentByMe =
                              message['senderId'] == _currentUser?.uid;
                          var messageData =
                              message.data() as Map<String, dynamic>;
                          String type = messageData.containsKey('type')
                              ? messageData['type']
                              : 'text';

                          if (type == 'poll') {
                            return _buildPollMessage(message);
                          }

                          return Align(
                            alignment: isSentByMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSentByMe
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: isSentByMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['sender'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(message['text'] ?? '',
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          );
                        });
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
                            hintText: 'Enter message',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // API Tab
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('apiChat')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // return ListView.builder(
                    //   itemCount: snapshot.data!.docs.length,
                    //   itemBuilder: (context, index) {
                    //     var message = snapshot.data!.docs[index];
                    //     return Card(
                    //       margin: const EdgeInsets.symmetric(
                    //           vertical: 5, horizontal: 10),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(10.0),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               'Q: ${message['question']}',
                    //               style: const TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.bold),
                    //             ),
                    //             const SizedBox(height: 5),
                    //             Text(
                    //               'A: ${message['response']}',
                    //               style: const TextStyle(fontSize: 14),
                    //             ),
                    //             const SizedBox(height: 5),
                    //             Text(
                    //               'Sent by: ${message['sender']}',
                    //               style: const TextStyle(
                    //                   fontSize: 12, color: Colors.grey),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var message = snapshot.data!.docs[index];
                        bool isUserMessage = message['type'] == 'user';
                        // bool isApiMessage = message['type'] ==
                        //     'api'; // Check if the message is from the API

                        // return Card(
                        //   margin: const EdgeInsets.symmetric(
                        //       vertical: 5, horizontal: 10),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: Column(
                        //       crossAxisAlignment: isUserMessage
                        //           ? CrossAxisAlignment
                        //               .end // Align user messages to the right
                        //           : CrossAxisAlignment
                        //               .start, // Align API messages to the left
                        //       children: [
                        //         // Display sender information
                        //         Text(
                        //           isUserMessage ? (_currentUser?.displayName ?? 'Unknown') : 'SwizzleBot',
                        //           style: const TextStyle(
                        //             fontSize: 12,
                        //             color: Color.fromARGB(255, 62, 74, 106),
                        //           ),
                        //         ),
                        //         const SizedBox(height: 5),
                        //         // Display the message content
                        //         Text(
                        //           message['message'],
                        //           style: const TextStyle(fontSize: 16),
                        //         ),
                        //         const SizedBox(height: 5),
                        //         // Display timestamp (if available)
                        //       ],
                        //     ),
                        //   ),
                        // );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          elevation: 2, // Add a subtle shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isUserMessage
                                  ? 12
                                  : 4), // Rounded corners for user messages
                              topRight: Radius.circular(isUserMessage
                                  ? 4
                                  : 12), // Rounded corners for bot messages
                              bottomLeft: const Radius.circular(12),
                              bottomRight: const Radius.circular(12),
                            ),
                          ),
                          color: isUserMessage
                              ? Colors.blue[500]
                              : Colors
                                  .purple[50], // User: Blue, Bot: Light Purple
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: isUserMessage
                                  ? CrossAxisAlignment
                                      .end // Align user messages to the right
                                  : CrossAxisAlignment
                                      .start, // Align bot messages to the left
                              children: [
                                // Display sender information
                                Text(
                                  isUserMessage
                                      ? message['sender']
                                      : 'SwizzleBot',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUserMessage
                                        ? Colors.white
                                        : Colors.grey[
                                            700], // User: Light Grey, Bot: Dark Grey
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Display the message content
                                Text(
                                  message['message'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isUserMessage
                                        ? Colors.white
                                        : Colors
                                            .black, // User: White, Bot: Black
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
                        controller: _apiMessageController,
                        decoration: const InputDecoration(
                            hintText: 'Enter message to bot',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(
                      icon: _isLoading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.send),
                      onPressed: _isLoading ? null : _sendApiMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollMessage(DocumentSnapshot message) {
    List<dynamic> options = message['options'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(options.length, (index) {
              return ListTile(
                title: Text(options[index]['text']),
                subtitle: Text('Votes: ${options[index]['votes']}'),
                trailing: ElevatedButton(
                  onPressed: () => _vote(message.id, index),
                  child: const Text('Vote'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _copyGroupId() {
    Clipboard.setData(ClipboardData(text: widget.groupId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group ID copied')),
    );
  }

  void _createPoll() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController questionController = TextEditingController();
        List<TextEditingController> optionControllers = [
          TextEditingController(),
          TextEditingController()
        ];

        return AlertDialog(
          title: const Text('Create Poll'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration:
                    const InputDecoration(hintText: 'Enter poll question'),
              ),
              ...optionControllers.map((controller) => TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Enter option'),
                  )),
              TextButton(
                onPressed: () {
                  setState(() {
                    optionControllers.add(TextEditingController());
                  });
                },
                child: const Text('Add Option'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (questionController.text.isNotEmpty &&
                    optionControllers.any((c) => c.text.isNotEmpty)) {
                  _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .add({
                    'question': questionController.text,
                    'options': optionControllers
                        .map((c) => {'text': c.text, 'votes': 0})
                        .toList(),
                    'sender': _currentUser?.displayName ?? 'Anonymous',
                    'senderId': _currentUser?.uid,
                    'timestamp': FieldValue.serverTimestamp(),
                    'type': 'poll', // Identifies poll messages
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _vote(String messageId, int optionIndex) async {
    DocumentReference pollRef = _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(messageId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot pollSnapshot = await transaction.get(pollRef);
      if (!pollSnapshot.exists) return;

      List<dynamic> options = pollSnapshot['options'];
      options[optionIndex]['votes'] += 1;

      transaction.update(pollRef, {'options': options});
    });
  }
}
