import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});
  static const String routeName = '/ManageUserPage';

  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? personal;
  String? personalKey;
  late String displayName;
  late String uuid;
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchDetails();

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

  Future<void> fetchDetails() async {
    final ref = databaseReference.child('users');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final personalData = snapshot.value as Map<dynamic, dynamic>;
      personalData.forEach((key, value) {
        if (value["uuid"] == uuid) {
          setState(() {
            personal = {
              "displayName": value["displayName"],
              "email": value["email"],
              "mobile": value["mobile"],
              "city": value["city"],
              "address": value["address"],
            };
            personalKey = key;
          });
        }
      });
    } else {
      print("No Personal Details found");
    }
  }

  void navigateToEditpersonalUser() {
    if (personal != null && personalKey != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditpersonalUser(
            personal: personal!,
            personalKey: personalKey!,
          ),
        ),
      ).then((value) {
        if (value == true) {
          fetchDetails();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          '${displayName} - Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.blue.withOpacity(0.7),
      ),
      body: personal == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.lightBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Adjusted padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adjust size to fit content
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name : ${personal!["displayName"]}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Email : ${personal!["email"]}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Mobile NO : ${personal!["mobile"]}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text('City : ${personal!["city"]}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Address : ${personal!["address"]}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: navigateToEditpersonalUser,
                          child: Text("Edit Details", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
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

// EditpersonalUser class remains the same


class EditpersonalUser extends StatefulWidget {
  final Map<String, dynamic> personal;
  final String personalKey;

  const EditpersonalUser({super.key, required this.personal, required this.personalKey});

  @override
  _EditpersonalUserState createState() => _EditpersonalUserState();
}

class _EditpersonalUserState extends State<EditpersonalUser> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namecontroller.text = widget.personal["displayName"];
    mobileController.text = widget.personal["mobile"];
    addressController.text = widget.personal["address"];
  }

  Future<void> updatePersonal() async {
    Map<String, dynamic> updatedPersonal = {
      "displayName": namecontroller.text,
      "mobile": mobileController.text,
      "address": addressController.text,
    };

    await FirebaseDatabase.instance
        .ref('users/${widget.personalKey}') // Use personalKey instead of key
        .update(updatedPersonal);

    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Your Details'),
        backgroundColor: Colors.blue.withOpacity(0.7), // Light blue
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8), // Whitish background
              Colors.lightBlue.withOpacity(0.8), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: namecontroller,
              style: TextStyle(color: Colors.black), // Dark text color
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.black), // Dark label
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Dark border when focused
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: mobileController,
              style: TextStyle(color: Colors.black), // Dark text color
              decoration: InputDecoration(
                labelText: "Mobile No",
                labelStyle: TextStyle(color: Colors.black), // Dark label
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Dark border when focused
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              style: TextStyle(color: Colors.black), // Dark text color
              decoration: InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(color: Colors.black), // Dark label
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Dark border when focused
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: updatePersonal,
                child: Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800], // Dark button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  textStyle: TextStyle(color: Colors.white), // Whitish text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
