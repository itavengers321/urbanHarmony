import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/screens/view_designer.dart';
import 'dart:convert'; // For decoding Base64 images
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class DesignersSection extends StatefulWidget {
  const DesignersSection({super.key});
  static const String routeName = '/DesignersSection';

  @override
  State<DesignersSection> createState() => _DesignersSectionState();
}

class _DesignersSectionState extends State<DesignersSection> {
  late String displayName;
  final List<DesignerItem> designers = [];
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('profDetailsDesigner');
    

  @override
  void initState() {
    super.initState();
    fetchDesigners(); // Fetch data from Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName.toString();
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> fetchDesigners() async {
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        setState(() {
          designers.add(DesignerItem(
            fullName: value['fullName'] ?? 'Unknown Name',
            yearsOfExp: value['YearsOfExp']?.toString() ?? 'N/A',
            specialization: value['specializationController'] ?? 'No specialization',
            imageBase64: value['ImageBase64'] ?? '', 
            designerUuid: value['DesignerUuid'] ?? 'Unknown UUID',
          ));
        });
      });
    } else {
      print("No designers found");
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
          'Designer Profiles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Expanded(
                child: designers.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Show a loading indicator
                    : ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: designers.length,
                        itemBuilder: (context, index) {
                          return DesignerCard(item: designers[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignerCard extends StatelessWidget {
  final DesignerItem item;

  DesignerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.6), // Semi-transparent card
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.imageBase64.isNotEmpty
              ? Image.memory(base64Decode(item.imageBase64),
                  fit: BoxFit.cover, height: 200.0, width: double.infinity)
              : Image.asset('assets/default.jpg',
                  fit: BoxFit.cover, height: 200.0, width: double.infinity), // Default image
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.fullName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Experience: ${item.yearsOfExp} years',
                style: TextStyle(color: Colors.black54)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Specialization: ${item.specialization}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Container(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewDesigner(designerUuid: item.designerUuid), // Pass the correct designerUuid
                    ),
                  );
                },
                child: Text('View Profile'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}

class DesignerItem {
  final String fullName;
  final String yearsOfExp;
  final String specialization;
  final String imageBase64;
  final String designerUuid;

  DesignerItem({
    required this.fullName,
    required this.yearsOfExp,
    required this.specialization,
    required this.imageBase64,
    required this.designerUuid,
  });
}
