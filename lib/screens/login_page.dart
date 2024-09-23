import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/models/user_profile.dart';
import 'package:flutter_project_2208e/pages/register_page.dart';
import 'package:flutter_project_2208e/pages/register_page_consultant.dart';
import 'package:flutter_project_2208e/pages/sign_out.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/services/auth_service.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import 'package:flutter_project_2208e/services/validation.dart';
import 'package:flutter_project_2208e/widgets/beveled_button.dart';
import '../widgets/misc_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = '/LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _obscured;
  final userDao = UserProfileDao();
  final togglePasswordFocusNode = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  String profileStatus = "";
  User? user;
  UsersProfile? puser;

  String? email;
  String? password;

  @override
  void initState() {
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? email = user!.email;
        String? displayName = user!.displayName;
      }
    });

    _obscured = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login Page",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
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
        child: user == null
            ? getBody()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text('Welcome: ${user!.displayName}'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                String status = await searchUserByEmail(
                                    user!.email.toString());
                                setState(() {
                                  profileStatus = status;
                                });

                                profileVerification(context);
                                if (profileStatus != "de-activate") {
                                  navigateToHome(context);
                                }
                              },
                              child: Text("Press to enter"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                AuthenticateHelper().signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignOutPage()));
                              },
                              child: Text("Log out"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white.withOpacity(0.6), // Semi-transparent card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.lightBlue,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage("assets/images/loginpic.jpg"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 30,
                            focusNode: _focusEmail,
                            decoration: InputDecoration(
                              hintText: "Enter User Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(
                                  color:
                                      Colors.lightBlue), // Custom label color
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            onSaved: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 8,
                            focusNode: _focusPassword,
                            obscureText: !_obscured,
                            decoration: InputDecoration(
                              hintText: "Enter User Password",
                              prefixIcon: const Icon(Icons.key),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(
                                  color:
                                      Colors.lightBlue), // Custom label color
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                child: GestureDetector(
                                  onTap: _toggleObscured,
                                  child: Icon(_obscured
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            validator: validatePass,
                            onSaved: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              onPressSubmit();
                            },
                            child: Text("Login"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                            },
                            child: Text("Register"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPageConsultant()));
                            },
                            child: Text("Register as Designer"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
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

  Future<void> onPressSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      AuthenticateHelper()
          .signIn(email: email.toString(), password: password.toString())
          .then((result) async {
        if (result == null) {
          final user = FirebaseAuth.instance.currentUser;

          String status = await searchUserByEmail(user!.email.toString());
          setState(() {
            profileStatus = status;
          });

          profileVerification(context);

          if (profileStatus != "de-activate") {
            navigateToHome(context);
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result)));
        }
      });
    }
  }

  Future<String> searchUserByEmail(String email) async {
    puser = await userDao.searchByEmail(email);
    if (puser != null) {
      return puser!.status; // Profile found
    } else {
      return "registration detail missing"; // Profile not found
    }
  }

  void profileVerification(BuildContext context) {
    if (profileStatus.trim().toLowerCase() == "de-activate") {
      messageBox(
          context: context,
          title: "failure",
          message: "your profile is de-activated contact admin");
    }
  }

  void navigateToHome(BuildContext context) {
    if (puser != null) {
      String? role = puser?.type;
      switch (role) {
        case "admin":
          Navigator.pushReplacementNamed(context, PageRoutes.admin);
          break;
        case "user":
          Navigator.pushReplacementNamed(context, PageRoutes.home);
          break;
        case "designer":
          Navigator.pushReplacementNamed(context, PageRoutes.consultant);
          break;
        default:
      }
    }
  }

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (togglePasswordFocusNode.hasPrimaryFocus) {
        return;
      }
      togglePasswordFocusNode.canRequestFocus = false;
    });
  }
}
