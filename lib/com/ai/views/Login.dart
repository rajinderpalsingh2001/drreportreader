import 'package:drreportreader/com/ai/models/user.dart';
import 'package:drreportreader/com/ai/service/firestore_service.dart';
import 'package:drreportreader/com/ai/views/Home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

bool isPasswordHide = true;
bool isLoading = false;

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirestoreService firestoreService = FirestoreService();
  FirebaseFirestore firestore = FirestoreService.getFirestoreInstance();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  bool canLoginProceed = false;
  bool canSignUpProceed = false;

  bool isLogin = true;
  bool isAuthCheckLoading = true;

  final Future<SharedPreferences> storage = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () async {
      if (_auth.currentUser != null) {
        await firestoreService.updateLastOpened(_auth.currentUser!.uid);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      } else {
        setState(() {
          isAuthCheckLoading = false;
        });
      }
    });
  }

  isSignUpFormValid() {
    if (signupFormKey.currentState!.validate()) {
      setState(() {
        canSignUpProceed = true;
      });
    } else {
      setState(() {
        canSignUpProceed = false;
      });
    }
  }

  isLoginFormValid() {
    if (loginFormKey.currentState!.validate()) {
      setState(() {
        canLoginProceed = true;
      });
    } else {
      setState(() {
        canLoginProceed = false;
      });
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!canLoginProceed) return;
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = _auth.currentUser;
      await firestoreService.updateLastOpened(user!.uid);
      await firestoreService.getUserDetails(user.uid).then((value) async {
        await storage.then((pref) {
          pref.setString("name", value.name!);          
        });
      });

      if (user != null && !user.emailVerified) {
        myDialog("Error!", "Email not Verified");
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      }
      // User signed in, you can navigate to the next screen
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        myDialog("Attention!", "No Account exists for this Email. SignUp now");
      } else if (e.code == 'wrong-password') {
        myDialog("Error!", "Wrong Email/Password");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (!canSignUpProceed) return;
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? userDetails = _auth.currentUser;
      if (userDetails != null && !userDetails.emailVerified) {
        await userDetails.sendEmailVerification();
        myDialog("Important Notice!",
            "Kindly Confirm Your Email Address. We've Sent a Verification Link to Your Email Inbox.");
      }

      Map<String, dynamic> data = {
        "name": nameController.text,
        "email": emailController.text,
        "registeredOn": Timestamp.fromDate(DateTime.now()),
        "lastOpened": Timestamp.fromDate(DateTime.now()),
        "credits": 10,
      };
      await firestoreService
          .registerUser(_auth.currentUser!.uid, user.toObj(data))
          .then((value) {
        print(value);
      });

      // User signed up, you can navigate to the next screen
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        myDialog("Attention!", "Password is too weak");
      } else if (e.code == 'email-already-in-use') {
        myDialog(
            "Attention!", "Account Already Exists for this email. Login Now");
      }
    } catch (e) {
      myDialog("Error!", "Unexpected Error Occured");
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  myDialog(String title, String message) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            title: Text(title),
            content: Text(message)));
  }

  showResetPasswordDialog() {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              title: Text("Reset Password"),
              actions: [
                MaterialButton(
                  color: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  onPressed: () async {
                    if (emailController.text.isNotEmpty) {
                      try {
                        await _auth.sendPasswordResetEmail(
                            email: emailController.text);
                        Navigator.of(context).pop();
                        myDialog(
                            "Link Sent", "Password reset link sent to email");
                      } catch (e) {
                        myDialog(
                            "Link Sent", "Password reset link sent to email");
                      }
                    } else {
                      myDialog("Error!", "Not a valid Email Address");
                    }
                  },
                  child: Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
              content: TextFormField(
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: emailController,
                validator: (value) {
                  String value = emailController.text;
                  if (value == null || value.isEmpty) {
                    return 'Enter Email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your Email",
                    prefixIcon: Icon(Icons.email)),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        toolbarHeight: 80,
        // backgroundColor: Colors.purple.shade300,
        title: const Text("Dr. Report Reader"),
      ),
      floatingActionButton: isLogin
          ? !canLoginProceed
              ? Container()
              : FloatingActionButton(
                  backgroundColor: Colors.indigo,
                  onPressed: () {
                    _signInWithEmailAndPassword();
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Home()));
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Icon(Icons.arrow_forward),
                )
          : !canSignUpProceed
              ? Container()
              : FloatingActionButton(
                  backgroundColor: Colors.indigo,
                  onPressed: () {
                    _signUpWithEmailAndPassword();
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Home()));
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Icon(Icons.arrow_forward),
                ),
      body: isAuthCheckLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/logo.png",
                            scale: 3,
                          ))),
                  SingleChildScrollView(
                    child: Container(
                      // padding: EdgeInsets.only(bottom: 30),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0)),
                          color: Colors.white),
                      // margin: EdgeInsets.all(10.0),
                      child: isLogin
                          ? Form(
                              key: loginFormKey,
                              child: Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                          margin: EdgeInsets.only(
                                              left: 20.0,
                                              right: 10.0,
                                              top: 20.0,
                                              bottom: 10.0),
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ))),

                                  // ---------------------------------------------
                                  TextFieldCustom(
                                      controller: emailController,
                                      hintText: "Email",
                                      onChanged: (p0) {
                                        isLoginFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0,
                                          top: 10.0),
                                      icon: Icons.email,
                                      validator: () {
                                        String value = emailController.text;
                                        if (value == null || value.isEmpty) {
                                          return 'Enter Email';
                                        }
                                        return null;
                                      }),

                                  // ---------------------------------------------

                                  TextFieldCustom(
                                      controller: passwordController,
                                      hintText: "Password",
                                      onChanged: (p0) {
                                        isLoginFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0),
                                      icon: Icons.password,
                                      validator: () {
                                        String value = passwordController.text;

                                        if (value == null || value.isEmpty) {
                                          return 'Enter Password';
                                        }
                                        return null;
                                      }),
                                  // ---------------------------------------------

                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: MaterialButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(20.0),
                                                  bottomRight:
                                                      Radius.circular(20.0))),
                                          onPressed: () async {
                                            showResetPasswordDialog();
                                          },
                                          child: Text("Forgot Password?"))),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: MaterialButton(
                                        color: Colors.indigo,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomRight:
                                                    Radius.circular(20.0))),
                                        onPressed: () {
                                          setState(() {
                                            isLogin = false;
                                          });
                                        },
                                        child: Text(
                                          "Don't have Account?",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                            )
                          : Form(
                              key: signupFormKey,
                              child: Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                          margin: EdgeInsets.only(
                                              left: 20.0,
                                              right: 10.0,
                                              top: 20.0,
                                              bottom: 10.0),
                                          child: Text(
                                            "SignUp",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ))),

                                  // ---------------------------------------------
                                  TextFieldCustom(
                                      controller: nameController,
                                      hintText: "Name",
                                      onChanged: (p0) {
                                        isSignUpFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0,
                                          top: 10.0),
                                      icon: Icons.person,
                                      validator: () {
                                        String value = nameController.text;

                                        if (value == null || value.isEmpty) {
                                          return 'Enter Name';
                                        }
                                        return null;
                                      }),

                                  // ---------------------------------------------
                                  TextFieldCustom(
                                      controller: emailController,
                                      hintText: "Email",
                                      onChanged: (p0) {
                                        isSignUpFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0,
                                          top: 10.0),
                                      icon: Icons.email,
                                      validator: () {
                                        String value = emailController.text;

                                        if (value == null || value.isEmpty) {
                                          return 'Enter Email';
                                        }
                                        return null;
                                      }),

                                  // ---------------------------------------------
                                  TextFieldCustom(
                                      controller: passwordController,
                                      hintText: "Password",
                                      onChanged: (p0) {
                                        isSignUpFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0),
                                      icon: Icons.password,
                                      validator: () {
                                        String value = passwordController.text;

                                        if (value == null || value.isEmpty) {
                                          return 'Enter Password';
                                        }
                                        return null;
                                      }),
                                  TextFieldCustom(
                                      controller: confirmPasswordController,
                                      hintText: "Confirm Password",
                                      onChanged: (p0) {
                                        isSignUpFormValid();
                                      },
                                      marginGeometry: const EdgeInsets.only(
                                          bottom: 10.0,
                                          left: 10.0,
                                          right: 10.0),
                                      icon: Icons.password,
                                      validator: () {
                                        String value =
                                            confirmPasswordController.text;
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      }),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: MaterialButton(
                                        color: Colors.indigo,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomRight:
                                                    Radius.circular(20.0))),
                                        onPressed: () {
                                          setState(() {
                                            isLogin = true;
                                          });
                                        },
                                        child: Text(
                                          "Already have Account?",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TextFieldCustom extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  String hintText;
  Function(String) onChanged;
  Function() validator;
  EdgeInsetsGeometry marginGeometry;
  IconData icon;
  TextFieldCustom(
      {required this.controller,
      required this.onChanged,
      required this.hintText,
      required this.marginGeometry,
      required this.icon,
      required this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      margin: marginGeometry,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border color
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0))),
      child: Column(
        children: [
          TextFormField(
            keyboardType:
                hintText.contains("Email") ? TextInputType.emailAddress : null,
            obscureText: hintText.contains("Password") ? isPasswordHide : false,
            controller: controller,
            onChanged: (value) {
              onChanged(value); // Call the provided onChanged function
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              return validator();
            },
            decoration: InputDecoration(
              suffixIcon: Icon(icon),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20.0),
              hintText: hintText,
            ),
          ),
        ],
      ),
    );
  }
}
