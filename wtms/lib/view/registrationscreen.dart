import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _image;
  Uint8List? webImageBytes;
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Register Screen"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    extendBodyBehindAppBar: true,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: showSelectionDialog,
                      child: Container(
                        height: 200,
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: _image == null
                              ? const AssetImage("assets/images/camera.png")
                              : _buildProfileImage(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: registerUserDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2193b0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Register", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


void registerUserDialog() {
  String name = nameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text;
  String confirmPassword = confirmPasswordController.text;
  String phone = phoneController.text.trim();
  String address = addressController.text.trim();

  // Basic empty field check
  if (name.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty ||
      phone.isEmpty ||
      address.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  // Email format validation
  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  if (!emailRegex.hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid email address")),
    );
    return;
  }

  // Password length validation
  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password must be at least 6 characters")),
    );
    return;
  }

  // Password match check
  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  // Confirmation dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Register this account?"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            child: const Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
              registerUser();
            },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  void registerUser() {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    http.post(Uri.parse("${MyConfig.myurl}/wtms/php/register_worker.php"),
        body: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
        }).then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success!"),
          ));
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to register"),
          ));
        }
      }
    });
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectFromCamera();
                    },
                    child: const Text("From Camera")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectfromGallery();
                    },
                    child: const Text("From Gallery"))
              ],
            ));
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) {
        // Read image bytes for web.
        webImageBytes = await pickedFile.readAsBytes();
      }
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  ImageProvider _buildProfileImage() {
    if (_image != null) {
      if (kIsWeb) {
        // For web, use MemoryImage.
        return MemoryImage(webImageBytes!);
      } else {
        // For mobile, convert XFile to File.
        return FileImage(File(_image!.path));
      }
    }
    return const AssetImage('assets/images/profile.png');
  }
}