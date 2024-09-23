import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Admin/addGalleryPicture.dart';
import 'package:flutter_project_2208e/Admin/addProduct.dart';
import 'package:flutter_project_2208e/Admin/adminpage.dart';
import 'package:flutter_project_2208e/Admin/galleryReviews.dart';
import 'package:flutter_project_2208e/Admin/manageuser.dart';
import 'package:flutter_project_2208e/Admin/review_product.dart';
import 'package:flutter_project_2208e/Admin/view_manageGallery_design.dart';
import 'package:flutter_project_2208e/Admin/view_products.dart';
import 'package:flutter_project_2208e/Consultant/addConsultationTime.dart';
import 'package:flutter_project_2208e/Consultant/add_project.dart';
import 'package:flutter_project_2208e/Consultant/consultant.dart';
import 'package:flutter_project_2208e/Consultant/create_professional_details.dart';
import 'package:flutter_project_2208e/Consultant/reviewsSection.dart';
import 'package:flutter_project_2208e/Consultant/viewConsulatations.dart';
import 'package:flutter_project_2208e/Consultant/view_personal_details.dart';
import 'package:flutter_project_2208e/Consultant/view_professionalDetails.dart';
import 'package:flutter_project_2208e/Consultant/view_projects.dart';
import 'package:flutter_project_2208e/firebase_options.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/screens/Contact_Us.dart';
import 'package:flutter_project_2208e/screens/MyDesigns.dart';
import 'package:flutter_project_2208e/screens/about_page.dart';
import 'package:flutter_project_2208e/screens/blog.dart';
import 'package:flutter_project_2208e/screens/cart_page.dart';
import 'package:flutter_project_2208e/screens/categories/Curtains.dart';
import 'package:flutter_project_2208e/screens/home_page.dart';
import 'package:flutter_project_2208e/screens/login_page.dart';
import 'package:flutter_project_2208e/screens/manage_user_page.dart';
import 'package:flutter_project_2208e/screens/order_page.dart';
import 'package:flutter_project_2208e/screens/product_view_page.dart';
import 'package:flutter_project_2208e/screens/show_consultaion_timing.dart';
import 'package:flutter_project_2208e/screens/show_designers.dart';
import 'package:flutter_project_2208e/screens/show_saved_items.dart';
import 'package:flutter_project_2208e/screens/sitemap.dart';
import 'package:flutter_project_2208e/screens/view_Gallery.dart';

import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FlutterFire());
}

class FlutterFire extends StatelessWidget {
  const FlutterFire({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
      title: 'Urban Harmony',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent, // Make the background transparent
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent app bar
          elevation: 0, // No shadow
        ),
        cardColor: Colors.white.withOpacity(0.6), // Semi-transparent light color
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Color.fromARGB(255, 50, 50, 50)), // Darker text
          titleLarge: TextStyle(
            color: Colors.black87, // Stronger contrast for titles
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, 
            backgroundColor: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded buttons
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return Container(
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
          child: child,
        );},
      routes: {
        PageRoutes.home: (context) => const HomePage(),
        PageRoutes.about: (context) => const AboutUsPage(),
        PageRoutes.muser: (context) => const ManageUserPage(),
        PageRoutes.prodview: (context) => const ProductViewPage(),
        PageRoutes.cart: (context) => const CartPage(),
        PageRoutes.order: (context) => const OrderPage(),
        PageRoutes.admin: (context) => const ManageAdminPage(),
        PageRoutes.consultant: (context) => const ManageConsultantPage(),
        PageRoutes.prodAdd: (context) => const AddDesigns(),
        PageRoutes.prodDisp: (context) => const DisplayProducts(),
        PageRoutes.manageUser: (context) => const UserManagementPage(),
        PageRoutes.createProfCons: (context) => const create_profileConsultant(),
        PageRoutes.viewProfCons: (context) => const ViewProfessionaldetails(),
        PageRoutes.viewPersCons: (context) => const ViewPersonaldetailsConsultant(),
        PageRoutes.addProjCons: (context) => const create_projectConsultant(),
        PageRoutes.viewProjCons: (context) => const ViewProjects(),
        PageRoutes.addConsulTime: (context) => const SetConsultationAvailabilityPage(),
        PageRoutes.viewConsulTime: (context) => const ViewConsultationsPage(),
        PageRoutes.showDesignU: (context) => const DesignersSection(),
        PageRoutes.lognPage: (context) => const LoginPage(),
        PageRoutes.savedItems: (context) => const viewSavedItems(),
        PageRoutes.contactUs: (context) => const ContactUsPage(),
        PageRoutes.sitemap: (context) => const SitemapPage(),
        PageRoutes.view_consultant_user: (context) => const ViewConsultationsUserPage(),
        PageRoutes.reviewConultant: (context) => const ReviewsSectionConsultant(),
        PageRoutes.addGallery: (context) => const addGalleryPicture(),
        PageRoutes.viewDesign: (context) => const ViewManagegalleryDesign(),
        PageRoutes.reviewProductAdmin: (context) => const ReviewProductAdmin(),
        PageRoutes.galleryPage: (context) => const GalleryPage(),
        PageRoutes.myDesigns: (context) => const MyDesigns(),
        PageRoutes.gallery_reviewsAdmin: (context) => const ReviewGalleryAdmin(),
        PageRoutes.blogPage: (context) => const BlogPage(),
    
      },
    );
  }
}
