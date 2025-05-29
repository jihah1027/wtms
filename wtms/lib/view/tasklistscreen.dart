import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/submitscreen.dart';

class TaskListScreen extends StatefulWidget {
  final User user;
  const TaskListScreen({super.key, required this.user});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];
  bool loading = true;
  String errorMessage = "";

  final Color primaryColor = const Color(0xFF2193b0);
  final Color secondaryColor = const Color(0xFF6dd5ed);

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_works.php"),
        body: {'worker_id': widget.user.userId.toString()},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData is Map && jsonData['status'] == 'success') {
          setState(() {
            tasks = jsonData['data'];
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
            errorMessage = "No tasks found or invalid response.";
          });
        }
      } else {
        setState(() {
          loading = false;
          errorMessage = "Failed to fetch tasks. Server error.";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'My Tasks',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : tasks.isEmpty
                  ? const Center(child: Text("No tasks assigned."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];
                        String status = task['status'].toString().toLowerCase();
                        bool isCompleted = status == 'success';

                        Color statusColor;
                        if (status == 'success') {
                          statusColor = Colors.green;
                        } else if (status == 'pending') {
                          statusColor = Colors.orange;
                        } else {
                          statusColor = primaryColor;
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task['title'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: statusColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Due Date: ${task['due_date']}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton.icon(
                                    onPressed: isCompleted
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SubmitCompletionScreen(
                                                  user: widget.user,
                                                  task: task,
                                                ),
                                              ),
                                            );
                                          },
                                    icon: Icon(
                                      isCompleted
                                          ? Icons.check_circle
                                          : Icons.upload,
                                    ),
                                    label: Text(
                                      isCompleted
                                          ? 'Submitted'
                                          : 'Submit Work',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCompleted
                                          ? Colors.grey
                                          : primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
