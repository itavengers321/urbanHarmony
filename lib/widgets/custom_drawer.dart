import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/pages/sign_out.dart';
import 'package:flutter_project_2208e/services/auth_service.dart';
import '../routes/route_pages.dart';

class CustNavigationDrawer extends StatelessWidget {
  const CustNavigationDrawer({super.key, required this.displayName});
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
                      color: Colors.white, // White text
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'User',
                    style: TextStyle(
                      color: Colors.white70, // Semi-transparent white
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
                  Navigator.pushReplacementNamed(context, PageRoutes.home),
            ),
            ExpansionTile(
              title: Text("Orders"),
              leading: Icon(Icons.list , color: Colors.lightBlue.withOpacity(0.6)),
              children: [
                createDrawerBodyItem(
                  icon: Icons.shopping_cart,
                  text: "Manage Cart",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.cart),
                ),
                createDrawerBodyItem(
                  icon: Icons.list,
                  text: "My Orders",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.order),
                ),
              ],
            ),
            createDrawerBodyItem(
              icon: Icons.manage_accounts,
              text: "Profile Settings",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.muser),
            ),
            createDrawerBodyItem(
              icon: Icons.design_services,
              text: "My Designs",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.myDesigns),
            ),
            createDrawerBodyItem(
              icon: Icons.design_services,
              text: "Saved Items",
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PageRoutes.savedItems),
            ),
            ExpansionTile(
              title: Text("Services"),
              leading: Icon(Icons.category , color: Colors.lightBlue.withOpacity(0.6),),
              children: [
                createDrawerBodyItem(
                  icon: Icons.inventory,
                  text: "Products",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.prodview),
                ),
                createDrawerBodyItem(
                  icon: Icons.design_services,
                  text: "Book/View Consultations",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.view_consultant_user),
                ),
                createDrawerBodyItem(
                  icon: Icons.design_services_rounded,
                  text: "Designers",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.showDesignU),
                ),
                createDrawerBodyItem(
                  icon: Icons.photo,
                  text: "Gallery",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.galleryPage),
                ),
                createDrawerBodyItem(
                  icon: Icons.article,
                  text: "Blogs and Articles",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.blogPage),
                ),
                createDrawerBodyItem(
                  icon: Icons.info,
                  text: "About Us",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, PageRoutes.about),
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
            const Divider(color: Colors.blueAccent), // Divider color
            const ListTile(
              title: Text(
                'App Version - 1.0.0\nUrban Harmony',
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
        Icon(icon, color: Colors.lightBlue), // Icons with light blue color
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.blueGrey), // Text color updated to blue-grey
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}
