import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Consultant/edit_projects.dart';

class ViewProjects extends StatefulWidget {
  const ViewProjects({super.key});
  static const String routeName = '/ViewProjects';

  @override
  State<ViewProjects> createState() => _ViewProjectsState();
}

class _ViewProjectsState extends State<ViewProjects> {
  late String consultantUuid;
  late String displayName;
  final List<Map<String, dynamic>> projectList = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        consultantUuid = user.uid.toString();
      });
      fetchProjects();
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> fetchProjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("DesignersProjects");
    ref.orderByChild("ConsultantUuid").equalTo(consultantUuid).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        projectList.clear();
        if (data != null) {
          data.forEach((key, value) {
            final project = Map<String, dynamic>.from(value);
            project['projectKey'] = key;
            projectList.add(project);
          });
        }
      });
    });
  }

  Future<void> deleteProject(String projectKey) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("DesignersProjects/$projectKey");
    await ref.remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Project Deleted Successfully",
          style: TextStyle(fontSize: 18),
        ),
      ));
      fetchProjects(); // Refresh project list
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to delete project: $error",
          style: TextStyle(fontSize: 18),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(
          displayName: displayName,
        ),
        appBar: AppBar(
          title: Text(
            'Designer Portal ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      body: projectList.isEmpty
          ? Center(
              child: Text(
                'No Projects Found',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: projectList.length,
              itemBuilder: (context, index) {
                final project = projectList[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProjectImage(project['Image1Base64']),
                            _buildProjectImage(project['Image2Base64']),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          project['projectName'] ?? 'No Name',
                          style: TextStyle(
                              fontSize: 22.0,
                              color: const Color.fromARGB(255, 16, 13, 13),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          project['projectDescription'] ?? 'No Description',
                          style: TextStyle(
                              fontSize: 16.0, color: const Color.fromARGB(255, 32, 27, 27)),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orangeAccent),
                              onPressed: () {
                                // Navigate to the Edit Page with project details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProjectPage(
                                      projectKey: project['projectKey'],
                                      project: project,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                deleteProject(project['projectKey']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProjectImage(String? base64Image) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: base64Image != null
          ? Image.memory(
              base64Decode(base64Image),
              fit: BoxFit.cover,
            )
          : Icon(Icons.broken_image, color: Colors.white),
    );
  }
}
