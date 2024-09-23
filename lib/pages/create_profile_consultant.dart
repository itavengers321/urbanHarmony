import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_2208e/pages/sign_out.dart';
import 'package:flutter_project_2208e/services/auth_service.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import '../models/user_profile.dart';
import '../services/validation.dart';
import 'package:flutter/material.dart';
import '../widgets/beveled_button.dart';

class UserProfileConsultant extends StatefulWidget {
  const UserProfileConsultant({super.key, required this.email});
  final String email;

  @override
  State<UserProfileConsultant> createState() => _UserProfileConsultantState();
}

class _UserProfileConsultantState extends State<UserProfileConsultant> {
  final _formKey = GlobalKey<FormState>();
  UserProfileDao userProfileDao = UserProfileDao();

  final _focusName = FocusNode();
  final _focusMobile = FocusNode();
  final _focusAddress = FocusNode();

  List<DropdownMenuItem<int>> cityList = [];
  int selectedCity = 0;

  void loadCityList() {
    cityList = [
      const DropdownMenuItem(value: 0, child: Text('Karachi')),
      const DropdownMenuItem(value: 1, child: Text('Lahore')),
      const DropdownMenuItem(value: 2, child: Text('Islamabad')),
      const DropdownMenuItem(value: 3, child: Text('Peshawar')),
      const DropdownMenuItem(value: 4, child: Text('Quetta')),
      const DropdownMenuItem(value: 5, child: Text('Rawalpindi')),
      const DropdownMenuItem(value: 6, child: Text('Multan')),
      const DropdownMenuItem(value: 7, child: Text('Faisalabad')),
      const DropdownMenuItem(value: 8, child: Text('Sialkot')),
      const DropdownMenuItem(value: 9, child: Text('Gujranwala')),
      const DropdownMenuItem(value: 10, child: Text('Bahawalpur')),
      const DropdownMenuItem(value: 11, child: Text('Sargodha')),
      const DropdownMenuItem(value: 12, child: Text('Hyderabad')),
      const DropdownMenuItem(value: 13, child: Text('Abbottabad')),
      const DropdownMenuItem(value: 14, child: Text('Mardan')),
      const DropdownMenuItem(value: 15, child: Text('Sukkur')),
    ];
  }

  String? displayName;
  String? userAddress;
  String? userMobile;

  @override
  void initState() {
    super.initState();
    loadCityList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create User Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 20,
                            focusNode: _focusName,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: "Display Name",
                              hintText: "Enter User Name",
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) =>
                                validateName(value, _focusName),
                            onSaved: (value) {
                              setState(() {
                                displayName = value;
                              });
                            },
                          ),
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 11,
                            focusNode: _focusMobile,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mobile_screen_share),
                              labelText: "Mobile No",
                              hintText: "Enter User Mobile No",
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                validateMobile(value, _focusMobile),
                            onSaved: (value) {
                              setState(() {
                                userMobile = value;
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButton<int>(
                              style: Theme.of(context).textTheme.bodyMedium,
                              hint: const Text('Select City'),
                              items: cityList,
                              value: selectedCity,
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = int.parse(value.toString());
                                });
                              },
                              isExpanded: true,
                            ),
                          ),
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 200,
                            maxLines: 4,
                            focusNode: _focusAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.location_city),
                              labelText: "Address",
                              hintText: "Enter User Delivery Address",
                            ),
                            keyboardType: TextInputType.multiline,
                            validator: (value) =>
                                validateText(value, _focusAddress),
                            onSaved: (value) {
                              setState(() {
                                userAddress = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          beveledButton(
                            title: "Create User",
                            onTap: () {
                              onPressSubmit();
                            },
                            color: Colors.lightBlueAccent, // Customize button color
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String city;
      switch (selectedCity) {
        case 0: city = "Karachi"; break;
        case 1: city = "Lahore"; break;
        case 2: city = "Islamabad"; break;
        case 3: city = "Peshawar"; break;
        case 4: city = "Quetta"; break;
        case 5: city = "Rawalpindi"; break;
        case 6: city = "Multan"; break;
        case 7: city = "Faisalabad"; break;
        case 8: city = "Sialkot"; break;
        case 9: city = "Gujranwala"; break;
        case 10: city = "Bahawalpur"; break;
        case 11: city = "Sargodha"; break;
        case 12: city = "Hyderabad"; break;
        case 13: city = "Abbottabad"; break;
        case 14: city = "Mardan"; break;
        case 15: city = "Sukkur"; break;
        default: city = "Unknown"; 
      }

      // Get the current authenticated user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update user's display name
        await user.updateDisplayName(displayName);
      }

      // Get user UUID
      String uuid = user!.uid.toString();

      // Create a new user profile object
      UsersProfile userProfile = UsersProfile(
        displayName: displayName.toString(),
        uuid: uuid,
        email: widget.email,
        mobile: userMobile.toString(),
        city: city,
        type: 'designer',
        status: 'active',
        address: userAddress.toString(),
      );

      // Save the user profile to the Firebase Realtime Database
      await userProfileDao.saveUser(userProfile);

      // Show a confirmation message
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User Created")));

      // Sign out the user and redirect to sign-out page
      await AuthenticateHelper().signOut();

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignOutPage()));
    }
  }
}
