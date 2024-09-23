import 'dart:convert'; // Add this for Base64 encoding
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Admin/view_products.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Consultant/database_prof.dart';
import 'package:flutter_project_2208e/Consultant/view_professionalDetails.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase is initialized

class create_profileConsultant extends StatefulWidget {
  const create_profileConsultant({super.key});
  static const String routeName = '/create_profileConsultant';

  @override
  State<create_profileConsultant> createState() => _create_profileConsultantState();
}

class _create_profileConsultantState extends State<create_profileConsultant> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Uint8List? webImage; // To store image bytes for web

  TextEditingController fullNamecontroller = TextEditingController();
  TextEditingController YearsOfExpController = TextEditingController();
  TextEditingController specializationController = TextEditingController();

  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

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
      // For web, get the image as bytes
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
        (!kIsWeb && selectedImage == null) ||
        fullNamecontroller.text.isEmpty ||
        YearsOfExpController.text.isEmpty ||
        specializationController.text.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please fill all fields and select an image.",
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

      Map<String, dynamic> addProfDetail = {
        "ImageBase64": base64Image, // Store image as Base64 string
        "fullName": fullNamecontroller.text,
        "YearsOfExp": YearsOfExpController.text,
        "specializationController": specializationController.text,
        "DesignerUuid": uuid,
      };

      // Add product details to the 'products' node in Realtime Database
      await DatabaseMethods_prof().addprofessionalDeatils(addProfDetail).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Professional Details set  Successfully",
            style: TextStyle(fontSize: 18),
          ),
        ));

        setState(() {
          selectedImage = null;
          webImage = null;
          fullNamecontroller.clear();
          YearsOfExpController.clear();
          specializationController.clear();
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewProfessionaldetails()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to add professional details: $e",
          style: TextStyle(fontSize: 18),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(
          displayName: displayName,
        ),
        appBar: AppBar(
          title: Text(
            'Designer Portal ',
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
                "Upload Profile Picture",
                style: TextStyle(
                    color: Colors.white,
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
                            height: 150,
                            width: 150,
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
              _buildTextField("Full Name : ", "Enter Full Name",
                  fullNamecontroller),
              SizedBox(height: 20.0),
              _buildTextField("Years of Experience : ",
                  "Enter Years of Experience", YearsOfExpController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[0-9]*[.,]?[0-9]*$'))
                  ]),
              SizedBox(height: 20.0),
              _buildTextField("Specialization : ", "Enter your Specialization",
                  specializationController,
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
                    'Upload Details',
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

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white, // Change label color to white
              fontSize: 20.0,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: Colors.white), // Change text color to white
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white), // Change border color
            ),
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey[400]), // Change hint text color
            filled: true,
            fillColor: Colors.black54, // Background color of the text field
          ),
        ),
      ],
    );
  }
}
