import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import 'package:intl/intl.dart'; // For formatting dates and times

class SetConsultationAvailabilityPage extends StatefulWidget {
  

  const SetConsultationAvailabilityPage({super.key});
  static const String routeName = '/SetConsultationAvailabilityPage';

  @override
  _SetConsultationAvailabilityPageState createState() =>
      _SetConsultationAvailabilityPageState();
}

class _SetConsultationAvailabilityPageState
    extends State<SetConsultationAvailabilityPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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



  final DatabaseReference _consultationRef =
      FirebaseDatabase.instance.ref('consultations');

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitAvailability() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select both date and time"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Format the date and time
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime = selectedTime!.format(context);

    // Save to Firebase Realtime Database
    await _consultationRef.push().set({
      'consultantUid': uuid,
      'userUid': 'none', // Default to none
      'status': 'available', // Default status
      'date': formattedDate,
      'time': formattedTime,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Consultation slot added successfully"),
          backgroundColor: Colors.greenAccent,
        ),
      );
    
    Navigator.pushReplacementNamed(context, PageRoutes.addConsulTime);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add consultation slot: $error"),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            'Set Consultations Time  ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Select Date" ,style: TextStyle(color: Colors.black),),
              subtitle: Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : "No date selected",
                style: TextStyle(color: Colors.black),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("Select Time" , style: TextStyle(color: Colors.black),),
              subtitle: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : "No time selected",
                style: TextStyle(color: Colors.black),
              ),
              trailing: Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitAvailability,
              child: Text("Submit Availability" , style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
