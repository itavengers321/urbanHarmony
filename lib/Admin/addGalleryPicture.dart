import 'dart:convert'; // Add this for Base64 encoding
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_2208e/Admin/adminpage.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Admin/database.dart';
import 'package:flutter_project_2208e/Admin/view_manageGallery_design.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is initialized

class addGalleryPicture extends StatefulWidget {
  const addGalleryPicture({super.key});
  static const String routeName = '/addGalleryPicture';

  @override
  State<addGalleryPicture> createState() => _addGalleryPictureState();
}

class _addGalleryPictureState extends State<addGalleryPicture> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Uint8List? webImage; // To store image bytes for web

  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  // Categories
  String? selectedRoomType;
  String? selectedTheme;
  String? selectedColorScheme;

  // Room Type options
  final List<String> roomTypes = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Others'
  ];

  // Theme/Style options
  final List<String> themes = [
    'Modern',
    'Rustic',
    'Minimalist',
    'Industrial',
    'Others'
  ];

  // Color Scheme options
  final List<String> colorSchemes = [
    'Neutral',
    'Bold',
    'Pastel',
    'Dark',
    'Others'
  ];

  @override
  void initState() {
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

  Future<void> getImage() async {
    if (kIsWeb) {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageBytes = await image.readAsBytes(); // Get image bytes for web
        setState(() {
          webImage = imageBytes; // Set the state after getting the bytes
        });
      }
    } else {
      // For mobile, pick the image as a File
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage =
              File(image.path); // Set the state after picking the image
        });
      }
    }
  }

  Future<void> uploadItem() async {
    if ((kIsWeb && webImage == null) ||
        (!kIsWeb && selectedImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please select an image.",
          style: TextStyle(fontSize: 18),
        ),
      ));
      return;
    }

    if (selectedRoomType == null ||
        selectedTheme == null ||
        selectedColorScheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please select all categories.",
          style: TextStyle(fontSize: 18),
        ),
      ));
      return;
    }

    try {
      // Convert image to Base64 format
      String base64Image;
      if (kIsWeb) {
        base64Image =
            base64Encode(webImage!); // For web, convert bytes to Base64
      } else {
        base64Image = base64Encode(selectedImage!
            .readAsBytesSync()); // For mobile, read file as bytes and convert to Base64
      }

      String pickey = randomBetween(100000, 999999).toString();

      Map<String, dynamic> addProduct = {
        "ImageBase64": base64Image, // Store image as Base64 string
        "prokey": pickey,
        "tobeShown": "yes",
        "roomType": selectedRoomType,
        "theme": selectedTheme,
        "colorScheme": selectedColorScheme,
      };

      await DatabaseMethodsGallery().addProduct(addProduct).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Design Added Successfully to Gallery",
            style: TextStyle(fontSize: 18),
          ),
        ));

        setState(() {
          selectedImage = null;
          webImage = null;
          selectedRoomType = null;
          selectedTheme = null;
          selectedColorScheme = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewManagegalleryDesign()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to add Picture: $e",
          style: TextStyle(fontSize: 18),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'Add Gallery Design',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload Design",
                style: TextStyle(
                    color: const Color.fromARGB(62, 116, 102, 102),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 20.0),
              selectedImage == null && webImage == null
                  ? GestureDetector(
                      onTap: getImage,
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(30.0)),
                          child: kIsWeb
                              ? Image.memory(
                                  webImage!, // Display web image from bytes
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  selectedImage!, // Display mobile image from file
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),
              SizedBox(height: 20.0),
              // Room Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedRoomType,
                decoration: InputDecoration(labelText: "Room Type"),
                items: roomTypes
                    .map((room) =>
                        DropdownMenuItem(value: room, child: Text(room)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoomType = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              // Theme/Style Dropdown
              DropdownButtonFormField<String>(
                value: selectedTheme,
                decoration: InputDecoration(labelText: "Theme/Style"),
                items: themes
                    .map((theme) =>
                        DropdownMenuItem(value: theme, child: Text(theme)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTheme = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              // Color Scheme Dropdown
              DropdownButtonFormField<String>(
                value: selectedColorScheme,
                decoration: InputDecoration(labelText: "Color Scheme"),
                items: colorSchemes
                    .map((color) =>
                        DropdownMenuItem(value: color, child: Text(color)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColorScheme = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue,
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  onPressed: uploadItem,
                  child: Text(
                    'Upload Picture',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
