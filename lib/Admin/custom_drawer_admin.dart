import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/pages/sign_out.dart';
import 'package:flutter_project_2208e/services/auth_service.dart';
import '../routes/route_pages.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key, required this.displayName});
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
                    'Admin',
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
                  Navigator.pushReplacementNamed(context, PageRoutes.admin),
            ),
            ExpansionTile(
              title: Text("Products"),
              leading: Icon(Icons.shopping_cart , color: Colors.lightBlue.withOpacity(0.6),),
              children: [
                createDrawerBodyItem(
                  icon: Icons.add,
                  text: "Add Product",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.prodAdd),
                ),
                createDrawerBodyItem(
                  icon: Icons.view_list,
                  text: "View Products",
                  onTap: () => Navigator.pushReplacementNamed(
                      context, PageRoutes.prodDisp),
                ),
              ],
            ),
            createDrawerBodyItem(
              icon: Icons.manage_accounts,
              text: "Manage Users",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.manageUser),
            ),
            ExpansionTile(
              title: Text("Gallery Designs"),
              leading: Icon(Icons.image ,color: Colors.lightBlue.withOpacity(0.6),),
              children: [
                createDrawerBodyItem(
                  icon: Icons.add,
                  text: "Add Gallery Design",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.addGallery),
                ),
                createDrawerBodyItem(
                  icon: Icons.view_list,
                  text: "Manage Gallery Designs",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.viewDesign),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Reviews"),
              leading: Icon(Icons.rate_review , color: Colors.lightBlue.withOpacity(0.6),),
              children: [
                createDrawerBodyItem(
                  icon: Icons.rate_review_rounded,
                  text: "Products Reviews",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.reviewProductAdmin),
                ),
                createDrawerBodyItem(
                  icon: Icons.rotate_90_degrees_ccw,
                  text: "Gallery Designs Reviews",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.gallery_reviewsAdmin),
                ),
              ],
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
            const Divider(color: Colors.blueAccent),
            const ListTile(
              title: Text(
                'App Version - 1.1.0\nUrban Harmony',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
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
