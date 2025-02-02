import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:swizzle_frontend/screens/chatbot.dart';
import 'package:swizzle_frontend/screens/groupChatRoom.dart';
import 'package:swizzle_frontend/screens/community.dart';
import 'package:swizzle_frontend/screens/itineraryPage.dart';
import 'package:swizzle_frontend/screens/profile.dart';
// import 'package:swizzle_frontend/screens/showGroups.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // To track selected navigation index

  User? _user; // Firebase Auth user object
  String? userId; // Firebase Auth user ID
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
    _initializePages();
  }
  String userid = "";

  // Fetch the logged-in user data
  void _fetchLoggedInUser() {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      // Use displayName or email as username
      setState(() {
        userId = _user!.uid;
        if (userId != null) {
          userid = userId!;
        }
      });
    }
  }

    void _initializePages() {
    _pages = [
      ItineraryPage(),
      ApiChatUI(),
      CommunityPage(),
      GroupsPage(),
    ];
  }

  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(
          onTap: () {
            // Handle drawer logic if needed
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  // Navigate to the Profile Page when clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                iconSize: 55,
              ),
              Image.asset(
                'lib/assets/logo.png', // Replace with your logo path
                height: 80,
                width: 80,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white, // Background color for the body
        color: Colors.black, // Color of the curved bar
        buttonBackgroundColor: Colors.black, // Color of the selected button
        height: 60.0,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.api, size: 30, color: Colors.white),
          Icon(Icons.group, size: 30, color: Colors.white),
          Icon(Icons.chat, size: 30, color: Colors.white),
        ],
        onTap: _onItemTapped,
      ),
      backgroundColor: Colors.white,
    );
  }
}
