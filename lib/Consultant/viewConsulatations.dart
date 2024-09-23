import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';

class ViewConsultationsPage extends StatefulWidget {
  const ViewConsultationsPage({super.key});
  static const String routeName = '/ViewConsultationsPage';

  @override
  _ViewConsultationsPageState createState() => _ViewConsultationsPageState();
}

class _ViewConsultationsPageState extends State<ViewConsultationsPage> {
  late String displayName;
  late String uuid;
  final DatabaseReference _consultationRef = FirebaseDatabase.instance.ref('consultations');
  
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
    final snapshot = await _consultationRef.orderByChild('consultantUid').equalTo(uuid).once();

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

  Future<void> _deleteConsultation(String key) async {
    await _consultationRef.child(key).remove();
    _fetchConsultations(); // Refresh the consultations list after deletion
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consultation removed successfully!')));
  }

  Future<void> _cancelConsultation(String key) async {
    await _consultationRef.child(key).update({'status': 'cancelled'});
    _fetchConsultations(); // Refresh the consultations list after update
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consultation cancelled successfully!')));
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
      drawer: ConsultantCustomDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text('View Consultations', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: consultations.isEmpty
            ? Center(child: Text('No consultations found.', style: TextStyle(color: Colors.white)))
            : ListView.builder(
                itemCount: consultations.length,
                itemBuilder: (context, index) {
                  final consultation = consultations[index];
                  final String status = consultation['status'] ?? 'unknown';
                  final String date = consultation['date'] ?? 'unknown';
                  final String time = consultation['time'] ?? 'unknown';
                  final String key = consultation['key']; // Firebase key
                  final String userUuid = consultation['userUid'] ?? 'unknown'; // Ensure a default value

                  return Card(
                    color: Colors.black54,
                    child: ListTile(
                      title: Text('Date: $date, Time: $time', style: TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $status', style: TextStyle(color: status == 'booked' ? Colors.red : Colors.green)),
                          if (status == 'booked') ...[
                            SizedBox(height: 4), 
                            FutureBuilder<List<String>>(
                              future: fetchUserData(userUuid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  print('Error fetching user data for userUuid: $userUuid');
                                  return Text('Error fetching user data');
                                } else {
                                  final userData = snapshot.data!;
                                  return Column(
                                    children: [
                                      Text('Client: ${userData[0]}', style: TextStyle(color: Colors.white70)),
                                      SizedBox(height: 4),
                                      Text('Client Email: ${userData[1]}', style: TextStyle(color: Colors.white70)),
                                      SizedBox(height: 4),
                                      Text('Client No: ${userData[2]}', style: TextStyle(color: Colors.white70)),
                                    ],
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
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteConsultation(key),
                          ),
                          // Cancel button (only if the consultation is booked)
                          if (status == 'booked')
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
