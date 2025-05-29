import 'package:flutter/material.dart';
import 'package:wtms/model/user.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/registrationscreen.dart';
import 'package:wtms/view/profilescreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> { 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
        backgroundColor: Color(0xFF6dd5ed),
        leading: IconButton(  // Add IconButton here
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)), // Pass the user data
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the image and text
          children: [
            Text(
              "Welcome to WTMS",
              style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 76, 66, 191)),
              textAlign: TextAlign.center,
            ),
            Image.asset(
              "assets/images/welcome.png", // The image path
              scale: 5.5, // Adjust the scale as needed
            ),// Add some spacing between the image and text
            Text(
              "${widget.user.userName}",
              style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 76, 66, 191)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Add new product screen later"),
            ));
          }
        },
        backgroundColor: Color(0xFF2193b0),
        child: const Icon(
          Icons.navigate_next,
          color: Colors.white,
          ), 
      ),
    );
  }
}