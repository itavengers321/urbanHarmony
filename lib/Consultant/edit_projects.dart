import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProjectPage extends StatefulWidget {
  final String projectKey;
  final Map<String, dynamic> project;

  const EditProjectPage({
    required this.projectKey,
    required this.project,
    Key? key,
  }) : super(key: key);

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();
  Uint8List? selectedImage1;
  Uint8List? selectedImage2;

  @override
  void initState() {
    super.initState();
    projectNameController.text = widget.project['projectName'] ?? '';
    projectDescriptionController.text = widget.project['projectDescription'] ?? '';
    
    if (widget.project['Image1Base64'] != null) {
      selectedImage1 = base64Decode(widget.project['Image1Base64']);
    }
    if (widget.project['Image2Base64'] != null) {
      selectedImage2 = base64Decode(widget.project['Image2Base64']);
    }
  }

  Future<void> pickImage1() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        selectedImage1 = await pickedFile.readAsBytes();
      });
    }
  }

  Future<void> pickImage2() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        selectedImage2 = await pickedFile.readAsBytes();
      });
    }
  }

  Future<void> updateProject() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("DesignersProjects/${widget.projectKey}");

    String? base64Image1;
    String? base64Image2;

    if (selectedImage1 != null) {
      base64Image1 = base64Encode(selectedImage1!);
    }

    if (selectedImage2 != null) {
      base64Image2 = base64Encode(selectedImage2!);
    }

    await ref.update({
      'projectName': projectNameController.text,
      'projectDescription': projectDescriptionController.text,
      if (base64Image1 != null) 'Image1Base64': base64Image1,
      if (base64Image2 != null) 'Image2Base64': base64Image2,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Project Updated Successfully",
          style: TextStyle(fontSize: 18),
        ),
      ));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to update project: $error",
          style: TextStyle(fontSize: 18),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Project"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: projectNameController,
                style: TextStyle(color: Colors.black), // White text color
                decoration: InputDecoration(
                  labelText: "Project Name",
                  labelStyle: TextStyle(color: Colors.black), // White label
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // White border when focused
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: projectDescriptionController,
                style: TextStyle(color: Colors.black), // White text color
                decoration: InputDecoration(
                  labelText: "Project Description",
                  labelStyle: TextStyle(color: Colors.black), // White label
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // White border when focused
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImage1,
                    child: Text("Pick Image 1"),
                  ),
                  SizedBox(width: 10),
                  selectedImage1 != null
                      ? Image.memory(
                          selectedImage1!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : widget.project['Image1Base64'] != null
                          ? Image.memory(
                              base64Decode(widget.project['Image1Base64']),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey,
                              child: Icon(Icons.broken_image),
                            ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImage2,
                    child: Text("Pick Image 2"),
                  ),
                  SizedBox(width: 10),
                  selectedImage2 != null
                      ? Image.memory(
                          selectedImage2!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : widget.project['Image2Base64'] != null
                          ? Image.memory(
                              base64Decode(widget.project['Image2Base64']),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey,
                              child: Icon(Icons.broken_image),
                            ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: updateProject,
                child: Text("Update Project"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
