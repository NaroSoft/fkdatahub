import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/Authentication/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpForm extends StatefulWidget {
  final String username, user_id;
  const SignUpForm({Key? key, required this.username, required this.user_id});
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isLoading = false;

  TextEditingController newpassController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.text,
            controller: newpassController,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            obscureText: true,
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "New Password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock_open),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: confirmpassController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Confirm Password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
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
                if (newpassController.text == confirmpassController.text) {
                  FocusScope.of(context).unfocus();

                  setState(() => _isLoading = true);
                  //await Future.delayed(Duration(seconds: 2));

                  Map<String, dynamic> UserData = Map<String, dynamic>();

                  UserData["password"] = newpassController.text;

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
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(width: 24),
                      Text(
                        "Please Wait....",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                : const Text(
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
