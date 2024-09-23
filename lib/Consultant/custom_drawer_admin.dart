import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/pages/sign_out.dart';
import 'package:flutter_project_2208e/services/auth_service.dart';
import '../routes/route_pages.dart';

class ConsultantCustomDrawer extends StatelessWidget {
  const ConsultantCustomDrawer({super.key, required this.displayName});
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white.withOpacity(0.6), // Transparent whitish background
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.6), // Light blue transparent header
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Designer',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            createDrawerBodyItem(
              icon: Icons.home,
              text: "Home",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.consultant),
            ),
            ExpansionTile(
              title: Text("Profile"),
              leading: Icon(Icons.person , color: Colors.lightBlue.withOpacity(0.6)),
              children: [
                createDrawerBodyItem(
                  icon: Icons.contact_page,
                  text: "View Professional Profile",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.viewProfCons),
                ),
                createDrawerBodyItem(
                  icon: Icons.contact_page,
                  text: "View Personal Details",
                  onTap: () => Navigator.pushReplacementNamed(
                      context, PageRoutes.viewPersCons),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Projects"),
              leading: Icon(Icons.work,color: Colors.lightBlue.withOpacity(0.6)),
              children: [
                createDrawerBodyItem(
                  icon: Icons.add,
                  text: "Add Your Projects",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.addProjCons),
                ),
                createDrawerBodyItem(
                  icon: Icons.view_list,
                  text: "View My Portfolio",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.viewProjCons),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Consultations"),
              leading: Icon(Icons.schedule,color: Colors.lightBlue.withOpacity(0.6)),
              children: [
                createDrawerBodyItem(
                  icon: Icons.access_time,
                  text: "Set Consultation Timings",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.addConsulTime),
                ),
                createDrawerBodyItem(
                  icon: Icons.view_list,
                  text: "View Consultations",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.viewConsulTime),
                ),
              ],
            ),
            createDrawerBodyItem(
              icon: Icons.rate_review,
              text: "Reviews",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.reviewConultant),
            ),
            createDrawerBodyItem(
              icon: Icons.logout,
              text: "Log Out",
              onTap: () {
                AuthenticateHelper().signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignOutPage()));
              }),
            const Divider(color: Colors.blueAccent), // Divider color
            const ListTile(
              title: Text(
                'App Version - 1.1.0',
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget createDrawerBodyItem({
  required IconData icon,
  required String text,
  required GestureTapCallback onTap,
}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon, color: Colors.lightBlue),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.blueGrey),
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}
