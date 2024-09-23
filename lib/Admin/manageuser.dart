import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/Admin/adminpage.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  static const String routeName = '/UserManagementPage';

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> users = [];

  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the page loads

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        uuid = user.uid.toString();
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(uuid);
    connectedRef.keepSynced(true);
  }

  Future<void> fetchUsers() async {
    final ref =
        databaseReference.child('users'); // Assuming 'users' is the node
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;

      userData.forEach((key, value) {
        if (value["type"] == "user") {
          // Filter by type
          setState(() {
            users.add({
              "displayName": value["displayName"],
              "email": value["email"],
              "uuid": key, // Store the UUID
              "status": value["status"] ?? "active", // Add status field
            });
          });
        }
      });
    } else {
      print("No users found");
    }
  }

  Future<void> deleteUser(String uuid) async {
    await databaseReference.child('users/$uuid').remove();
    setState(() {
      users.removeWhere((user) => user["uuid"] == uuid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User deleted successfully!"),
      ));
    });
  }

  Future<void> deactivateUser(String uuid) async {
    await databaseReference
        .child('users/$uuid')
        .update({"status": "de-activate"});
    setState(() {
      users.firstWhere((user) => user["uuid"] == uuid)["status"] =
          "de-activate";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("User de-activated successfully!"),
    ));
  }

  Future<void> activateUser(String uuid) async {
    await databaseReference.child('users/$uuid').update({"status": "active"});
    setState(() {
      users.firstWhere((user) => user["uuid"] == uuid)["status"] = "active";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("User activated successfully!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.white,
                  thickness: 10,
                  height: 30,
                );
              },
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display name and email vertically
                        Text('Name: ${user["displayName"]}'),
                        Text('Email: ${user["email"]}'),

                        SizedBox(height: 20), // Add some space before buttons

                        // Buttons arranged vertically
                        Row(
                          children: [
                            if (user["status"] == "active") ...[
                              ElevatedButton(
                                onPressed: () => deactivateUser(user["uuid"]),
                                child: Text("Deactivate" , style: TextStyle(color: Colors.black) ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 232, 231, 244)),
                              ),
                            ] else ...[
                              ElevatedButton(
                                onPressed: () => activateUser(user["uuid"]),
                                child: Text("Activate"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                              ),
                            ],
                            SizedBox(width: 10), // Add space between buttons
                            ElevatedButton(
                              onPressed: () => deleteUser(user["uuid"]),
                              child: Text("Delete"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
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
}


