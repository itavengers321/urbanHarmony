import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/screens/Contact_Us.dart';
import 'package:flutter_project_2208e/screens/show_consultaion_timing.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class myBookingsPage extends StatefulWidget {
  const myBookingsPage({super.key});
  static const String routeName = '/myBookingsPage';

  @override
  _myBookingsPageState createState() =>
      _myBookingsPageState();
}

class _myBookingsPageState extends State<myBookingsPage> {
  late String displayName;
  late String uuid;

  final DatabaseReference _consultationRef =
      FirebaseDatabase.instance.ref('consultations');

  List<Map<String, dynamic>> consultations = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName ?? "Unknown User";
        uuid = user.uid;
      });
      _fetchConsultations(); // Fetch consultations when the page is initialized
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> _fetchConsultations() async {
    final snapshot = await _consultationRef.orderByChild('userUid').equalTo(uuid).once();


    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        consultations = data.entries.map((entry) {
          final consultation = Map<String, dynamic>.from(entry.value);
          consultation['key'] = entry.key; // Save Firebase key for deletion
          return consultation;
        }).toList();
      });
    }
  }

  

  Future<void> _cancelConsultation(String key) async {
    await _consultationRef.child(key).update({'status': 'available'});
    await _consultationRef.child(key).update({'userUid': 'none'});
    _fetchConsultations(); // Refresh the consultations list after update
    
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Consultation Cancelled successfully!')));
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ViewConsultationsUserPage()));
  }

  Future<List<String>> fetchUserData(String userUuid) async {
    final DatabaseReference _userRef = FirebaseDatabase.instance.ref('users');
    final query =
        _userRef.orderByChild('uuid').equalTo(userUuid); // Query by uuid
    try {
      final snapshot = await query.once();

      if (snapshot.snapshot.exists) {
        // Firebase will return a map of matching records
        final dataMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

        // Extract the first entry (assuming there's only one user with this uuid)
        final firstUserKey = dataMap.keys.first;
        final userData = Map<String, dynamic>.from(dataMap[firstUserKey]);

        // Return the required fields (displayName, email, mobile)
        return [
          userData['displayName'] ?? 'N/A',
          userData['email'] ?? 'N/A',
          userData['mobile'] ?? 'N/A',
        ];
      } else {
        print('User not found for UUID: $userUuid');
        return ['N/A', 'N/A', 'N/A']; // Return default values if not found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return ['N/A', 'N/A', 'N/A']; // Return default values in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('My Consultations',
            style: Theme.of(context).textTheme.titleLarge),
            leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: consultations.isEmpty
            ? Center(
                child: Text('No consultations found.',
                    style: TextStyle(color: Colors.white)))
            : ListView.builder(
                itemCount: consultations.length,
                itemBuilder: (context, index) {
                  final consultation = consultations[index];
                  final String status = consultation['status'] ?? 'unknown';
                  final String date = consultation['date'] ?? 'unknown';
                  final String time = consultation['time'] ?? 'unknown';
                  final String key = consultation['key']; // Firebase key
                  final String userUuid = consultation['userUid'] ??
                      'none'; // Ensure a default value
                  final String consultantId = consultation['consultantUid'] ??
                      'none'; // Ensure a default value

                  return Card(
                    color:  status == 'booked'
                        ? Colors.grey
                        : Colors.black54, // Change card color if cancelled
                    child: ListTile(
                      title: Text(
                        'Date: $date, Time: $time',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: $status',
                            style: TextStyle(
                              color: status == 'booked'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          if ( status == 'booked') ...[
                            SizedBox(
                                height:
                                    4), // Space between status and next line
                            FutureBuilder<List<String>>(
                              future: fetchUserData(consultantId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasData) {
                                  final userData = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Consultant : ${userData[0]}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text('Email : ${userData[1]}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text('Mobile : ${userData[2]}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  );
                                } else {
                                  return Text(
                                    'No consultant data found.',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status == 'booked' && userUuid == uuid)
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.orange),
                              onPressed: () => _cancelConsultation(key),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      
    );
  }
}
