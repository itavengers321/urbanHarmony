import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/pages/create_profile_consultant.dart';
import 'package:flutter_project_2208e/screens/login_page.dart';
import '../services/auth_service.dart';
import '../services/validation.dart';
import '../widgets/beveled_button.dart';

class RegisterPageConsultant extends StatefulWidget {
  const RegisterPageConsultant({super.key});

  @override
  State<RegisterPageConsultant> createState() => _RegisterPageConsultantState();
}

class _RegisterPageConsultantState extends State<RegisterPageConsultant> {
  final _formKey = GlobalKey<FormState>();
  late bool _obscured;
  final togglePasswordFocusNode = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  String? email;
  String? password;

  @override
  void initState() {
    super.initState();
    _obscured = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register Page',
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
        child: SingleChildScrollView(
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
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelStyle: TextStyle(color: Colors.lightBlue), // Custom label color
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
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelStyle: TextStyle(color: Colors.lightBlue), // Custom label color
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
                                child: Text("Create User"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.lightBlue, // Text color
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
                                      MaterialPageRoute(builder: (context) => const LoginPage()));
                                },
                                child: Text("Login"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.lightBlue, // Text color
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
        ),
      ),
    );
  }

  void onPressSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AuthenticateHelper()
          .signUp(email: email.toString(), password: password.toString())
          .then((result) {
        if (result == null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfileConsultant(
                        email: email.toString(),
                      )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        }
      });
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
