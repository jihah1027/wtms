import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';

class SubmitCompletionScreen extends StatefulWidget {
  final User user;
  final Map task;

  const SubmitCompletionScreen({
    super.key,
    required this.user,
    required this.task,
  });

  @override
  State<SubmitCompletionScreen> createState() => _SubmitCompletionScreenState();
}

class _SubmitCompletionScreenState extends State<SubmitCompletionScreen> {
  final TextEditingController _completionController = TextEditingController();
  bool submitting = false;

  final Color primaryColor = const Color(0xFF2193b0);
  final Color secondaryColor = const Color(0xFF6dd5ed);

  void _submitWork() async {
    if (_completionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter what you completed')),
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/wtms/php/submit_work.php"),
      body: {
        'work_id': widget.task['work_id'].toString(),
        'worker_id': widget.user.userId.toString(),
        'submission_text': _completionController.text,
      },
    );

    setState(() {
      submitting = false;
    });

    var jsonData = jsonDecode(response.body);
    if (jsonData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission successful')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonData['message'] ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Work Completion'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: widget.task['title']),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Completion Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _completionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe what you have done...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                submitting
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitWork,
                          icon: const Icon(Icons.send),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
