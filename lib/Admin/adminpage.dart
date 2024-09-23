import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Admin/manageuser.dart';
import 'package:flutter_project_2208e/Admin/report_generate.dart';
import 'package:flutter_project_2208e/Admin/view_manageGallery_design.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class ManageAdminPage extends StatefulWidget {
  const ManageAdminPage({super.key});
  static const String routeName = '/ManageAdminPage';

  @override
  State<ManageAdminPage> createState() => _ManageAdminPageState();
}

class _ManageAdminPageState extends State<ManageAdminPage> {
  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  int totalUsers = 0;
  int totalOrders = 0;
  int totalDesigns = 0;

  @override
  void initState() {
    super.initState();
    fetchTotalUsers();
    fetchTotalOrders();
    fetchTotalDesigns();

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

  Future<void> fetchTotalUsers() async {
    DatabaseReference ref = databaseReference.child("users");
    ref.orderByChild("type").equalTo("user").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        totalUsers = data != null ? data.length : 0;
      });
    });
  }

  Future<void> fetchTotalOrders() async {
    DatabaseReference ref = databaseReference.child("orders");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        totalOrders = data != null ? data.length : 0;
      });
    });
  }

  Future<void> fetchTotalDesigns() async {
    DatabaseReference ref = databaseReference.child("galleryDesigns");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        totalDesigns = data != null ? data.length : 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'Admin Page',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDashboardCards(context),
              SizedBox(height: 20),
              _buildManageSection(context, 'Gallery Management',
                  Icons.photo_library, Colors.green, ViewManagegalleryDesign()),
              _buildManageSection(context, 'User Management', Icons.people,
                  Colors.orange, UserManagementPage()), // Update accordingly
              _buildManageSection(context, 'Reports', Icons.insert_chart,
                  Colors.blue, ReportsPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard('Pending Orders', '$totalOrders', Icons.hourglass_top,
            Colors.orange),
        _buildCard(
            'Total Designs', '$totalDesigns', Icons.format_paint, Colors.green),
        _buildCard('Active Users', '$totalUsers', Icons.people, Colors.blue),
      ],
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: Colors.white.withOpacity(0.9),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(count,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title,
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageSection(BuildContext context, String title, IconData icon,
      Color color, Widget navigateTo) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => navigateTo));
        },
      ),
    );
  }
}
