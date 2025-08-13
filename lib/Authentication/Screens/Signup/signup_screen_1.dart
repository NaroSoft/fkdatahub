import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../responsive.dart';

class SignUpScreen extends StatefulWidget {
  final String username, user_id;
  SignUpScreen({Key? key, required this.username, required this.user_id})
      : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: AppColors.secondaryBg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Responsive(
              mobile: MobileSignupScreen(
                username: widget.username,
                user_id: widget.user_id,
              ),
              desktop: MobileSignupScreen(
                  username: widget.username, user_id: widget.user_id),
              tablet: MobileSignupScreen(
                  username: widget.username, user_id: widget.user_id),
            ),
          ),
        ));
  }
}

class MobileSignupScreen extends StatefulWidget {
  final String username, user_id;
  MobileSignupScreen({Key? key, required this.username, required this.user_id})
      : super(key: key);
  @override
  _MobileSignupScreenState createState() => _MobileSignupScreenState();
}

class _MobileSignupScreenState extends State<MobileSignupScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  TextEditingController newpassController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 40,
        ),
        Text(
          "PASSWORD UPDATE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),

        SizedBox(
          height: 50,
        ),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/gif/search2.gif",
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
                //colorFilter: Colors.black12,
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: defaultPadding * 2),

        Row(
          children: [
            Spacer(),
            Expanded(
                flex: 8,
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: newpassController,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        obscureText: true,
                        onSaved: (email) {},
                        decoration: InputDecoration(
                          hintText: "New Password",
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Icon(Icons.lock_open),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding),
                        child: TextFormField(
                          controller: confirmpassController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Icon(Icons.lock),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      ElevatedButton(
                        onPressed: () async {
                          if (newpassController.text.isEmpty ||
                              confirmpassController.text.isEmpty) {
                            showEmptyDialog();
                          } else {
                            if (newpassController.text ==
                                confirmpassController.text) {
                              FocusScope.of(context).unfocus();

                              setState(() => _isLoading = true);
                              //await Future.delayed(Duration(seconds: 2));

                              Map<String, dynamic> UserData =
                                  new Map<String, dynamic>();

                              UserData["password"] = newpassController.text;
                              UserData["password_status"] = "Custom";

                              FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(widget.user_id)
                                  .update(UserData)
                                  .whenComplete(() {
                                setState(() => _isLoading = false);
                                Navigator.of(context).pop();
                              });
                            } else {
                              setState(() => _isLoading = false);
                              showErrorDialog();
                            }
                          }
                        },
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 24),
                                  Text(
                                    "Please Wait....",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            : Text(
                                "Update Password",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 30),
                      /*AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
          ),*/
                    ],
                  ),
                )),
            Spacer(),
          ],
        ),
        // const SocalSignUp()
      ],
    );
  }

  showErrorDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Warning Alert',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('Password does not match!'),
          actions: <Widget>[
            /*CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),*/
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  showEmptyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Warning Alert',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('One or All the fields is Empty!'),
          actions: <Widget>[
            /*CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),*/
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
