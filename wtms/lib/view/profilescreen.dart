import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wtms/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/mainscreen.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? _image;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text:widget.user.userId);
    nameController = TextEditingController(text: widget.user.userName);
    emailController = TextEditingController(text: widget.user.userEmail);
    phoneController = TextEditingController(text: widget.user.userPhone);
    addressController = TextEditingController(text: widget.user.userAddress);
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Profile Page"),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 40), // To offset AppBar
                      GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : const AssetImage("assets/images/profile.png") as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoField("Worker ID", idController.text, controller: idController, enabled: false),
                      _buildInfoField("Name", nameController.text, controller: nameController),
                      _buildInfoField("Email", emailController.text, controller: emailController),
                      _buildInfoField("Phone", phoneController.text, controller: phoneController),
                      _buildInfoField("Address", addressController.text, controller: addressController, maxLines: 3),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2193b0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
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
    ),
  );
}

  Widget _buildInfoField(String label, String value,
      {TextEditingController? controller, bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: controller != null ? enabled : false,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
  String fullName = nameController.text;
  String email = emailController.text;
  String phone = phoneController.text;
  String address = addressController.text;

  http.post(Uri.parse("${MyConfig.myurl}/wtms/php/update_profile.php"),
     headers: {
    "Content-Type": "application/x-www-form-urlencoded", // Tells PHP this is a real POST
  },
    body: {
      "worker_id": widget.user.userId ?? "",
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "address": address,
    },
  ).then((response) {
    print("Raw response: ${response.body}");

    // Try parsing manually for debugging
    if (response.statusCode == 200 && response.body.contains('status')) {
      Map<String, dynamic> jsondata = jsonDecode(response.body);

      if (jsondata['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile updated successfully"),
        ));

        setState(() {
          widget.user.userName = fullName;
          widget.user.userEmail = email;
          widget.user.userPhone = phone;
          widget.user.userAddress = address;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(user: widget.user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsondata['message'] ?? "Update failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid response from server"),
      ));
    }
  }).catchError((error) {
    print("HTTP error: $error");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Connection failed"),
    ));
  });
}
}

