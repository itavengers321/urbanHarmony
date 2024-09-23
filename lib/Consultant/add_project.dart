import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/consultant.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Consultant/database_prof.dart';
import 'package:image_picker/image_picker.dart';

class create_projectConsultant extends StatefulWidget {
  const create_projectConsultant({super.key});
  static const String routeName = '/create_projectConsultant';

  @override
  State<create_projectConsultant> createState() => _create_projectConsultantState();
}

class _create_projectConsultantState extends State<create_projectConsultant> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage1;
  File? selectedImage2;
  Uint8List? webImage1;
  Uint8List? webImage2;

  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();

  late String displayName;
  late String uuid;

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
  }

  Future<void> getImage(int imageNumber) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final imageBytes = await image.readAsBytes();
        setState(() {
          if (imageNumber == 1) {
            webImage1 = imageBytes;
          } else {
            webImage2 = imageBytes;
          }
        });
      } else {
        setState(() {
          if (imageNumber == 1) {
            selectedImage1 = File(image.path);
          } else {
            selectedImage2 = File(image.path);
          }
        });
      }
    }
  }

  Future<void> uploadProject() async {
    if ((kIsWeb && (webImage1 == null || webImage2 == null)) ||
        (!kIsWeb && (selectedImage1 == null || selectedImage2 == null)) ||
        projectNameController.text.isEmpty ||
        projectDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please fill all fields and select two images.",
          style: TextStyle(fontSize: 18),
        ),
      ));
      return;
    }

    try {
      String base64Image1, base64Image2;
      if (kIsWeb) {
        base64Image1 = base64Encode(webImage1!);
        base64Image2 = base64Encode(webImage2!);
      } else {
        base64Image1 = base64Encode(selectedImage1!.readAsBytesSync());
        base64Image2 = base64Encode(selectedImage2!.readAsBytesSync());
      }

      Map<String, dynamic> addProjectDetail = {
        "Image1Base64": base64Image1,
        "Image2Base64": base64Image2,
        "projectName": projectNameController.text,
        "projectDescription": projectDescriptionController.text,
        "ConsultantUuid": uuid,
      };

      await DatabaseMethods_project().addprojectDetails(addProjectDetail).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Project Details Added Successfully",
            style: TextStyle(fontSize: 18),
          ),
        ));

        setState(() {
          selectedImage1 = null;
          selectedImage2 = null;
          webImage1 = null;
          webImage2 = null;
          projectNameController.clear();
          projectDescriptionController.clear();
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageConsultantPage()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to add project details: $e",
          style: TextStyle(fontSize: 18),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'Add Project',
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
                "Upload Project Images",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 20.0),
              _buildImagePicker(1),
              SizedBox(height: 20.0),
              _buildImagePicker(2),
              SizedBox(height: 20.0),
              _buildTextField("Project Name: ", "Enter Project Name", projectNameController),
              SizedBox(height: 20.0),
              _buildTextField("Project Description: ", "Enter Project Description", projectDescriptionController),
              SizedBox(height: 20.0),
              Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue,
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  onPressed: uploadProject,
                  child: Text(
                    'Upload Project',
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

  Widget _buildImagePicker(int imageNumber) {
    Uint8List? webImage = imageNumber == 1 ? webImage1 : webImage2;
    File? selectedImage = imageNumber == 1 ? selectedImage1 : selectedImage2;

    return GestureDetector(
      onTap: () => getImage(imageNumber),
      child: Center(
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(20.0)),
            child: webImage == null && selectedImage == null
                ? Icon(Icons.camera_alt_outlined, color: Colors.black)
                : kIsWeb
                    ? Image.memory(webImage!, fit: BoxFit.contain)
                    : Image.file(selectedImage!, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white, 
              fontSize: 20.0, 
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.black54,
          ),
        ),
      ],
    );
  }
}
