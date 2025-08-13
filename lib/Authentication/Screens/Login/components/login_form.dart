import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/retaildata/retail_home.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key});
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(20)),
              child: */
          /*  const Center(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: "M",
                style: TextStyle(
                    color: Color.fromARGB(255, 29, 0, 194),
                    fontSize: 36,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "y-",
                style: TextStyle(
                    fontSize: 32,
                    color: Color.fromARGB(255, 19, 0, 194),
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "S",
                style: TextStyle(
                    fontSize: 36,
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 3, 0, 194),
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "chool",
                style: TextStyle(
                    fontSize: 32,
                    color: Color.fromARGB(255, 0, 45, 194),
                    fontWeight: FontWeight.bold),
              )
            ])),
          ),*/
          const SizedBox(
            height: 10,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Log into your account",
              style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
              style: const TextStyle(fontWeight: FontWeight.bold),
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              decoration: InputDecoration(
                hintText: "Your username",
                hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 10),
                  child: Container(
                    height: 43,
                    width: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      color: Color.fromARGB(255, 74, 103, 167),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )),
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            style: const TextStyle(fontWeight: FontWeight.bold),
            controller: passwordController,
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
                hintText: "Your password",
                hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 10),
                  child: Container(
                    height: 43,
                    width: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      color: Color.fromARGB(255, 74, 103, 167),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white70,
                    ),
                  ),
                )),
          ),
          const SizedBox(height: 40),
          Align(
              alignment: Alignment.center,
              child: Card(
                  elevation: 10,
                  child: InkWell(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        if (usernameController.text == "Narosoft" &&
                            passwordController.text == "1914") {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RetailHomePage()));
                        }else{
                          showErrorDialog("");
                        }
                        //Checking if username textfield not empty
                        /* if (usernameController.text.isNotEmpty) {
                          if (usernameController.text == "admin") {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Dashboard(
                                full_name: '',
                                user_contact: '',
                                user_email: '',
                                user_location: '',
                                user_image: '',
                                user_name: '',
                                user_status: '',
                              ),
                            ));
                          } else if (usernameController.text == "sms") {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SMSDashboard(
                                      full_name: '',
                                      user_contact: '',
                                      user_email: '',
                                      user_location: '',
                                      user_image: '',
                                      user_name: '',
                                      user_status: '',
                                    )));
                          } else if (usernameController.text == "smst") {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TeacherDashboard(
                                      full_name: '',
                                      user_contact: '',
                                      user_email: '',
                                      user_location: '',
                                      user_image: '',
                                      user_name: '',
                                      user_status: '',
                                    )));
                          } else if (usernameController.text == "naro") {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AccountDashboard(
                                full_name: '',
                                user_contact: '',
                                user_email: '',
                                user_location: '',
                                user_image: '',
                                user_name: '',
                                user_status: '',
                              ),
                            ));

                            // Navigator.of(context)
                            // .push(MaterialPageRoute(builder: (context)=>MainScreen()));
                          } else {
                            setState(() {
                              _isLoading = true;
                            });

                            QuerySnapshot chk = await FirebaseFirestore.instance
                                .collection("Users")
                                .where('email',
                                    isEqualTo: "${usernameController.text}")
                                .where('password',
                                    isEqualTo: "${passwordController.text}")
                                .get();
                            if (chk.docs.length == 0) {
                              setState(() {
                                _isLoading = false;
                              });

                              print('Invalid Username or Password');
                              showErrorDialog("");
                            } else {

                              //Checking if username password is the same in database
                                    if (chk.docs[0]["password_status"] == 'Default') {
                                      setState(() {
                                        _isLoading = false;
                                        passwordController.text = "";
                                        usernameController.text = "";
                                      });

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpScreen(
                                                    username:
                                                        chk.docs[0]["full_name"],
                                                    user_id: chk.docs[0]
                                                        ['worker_id'],
                                                  )));
                                    } else {

                                      setState(() {
                                        _isLoading = false;
                                        passwordController.text = "";
                                        usernameController.text = "";
                                      });

                                      //Checking User status
                                      if (chk.docs[0]["status"] == "Admin" ||
                                          chk.docs[0]["status"] ==
                                              "Assist. Admin") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Dashboard(
                                                      full_name: chk.docs[0]["full_name"],
                                                      user_name:
                                                          chk.docs[0]["username"],
                                                      user_image:
                                                          chk.docs[0]["image"],
                                                      user_contact:
                                                          chk.docs[0]["contact"],
                                                      user_location:
                                                          chk.docs[0]["location"],
                                                      user_email:
                                                          chk.docs[0]["email"],
                                                      user_status:
                                                          chk.docs[0]["status"],
                                                    )));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserDashboard(
                                                      // full_name: event.get("full_name"),
                                                      //user_name: "Frank",
                                                      user_id: chk.docs[0]["worker_id"],
                                                      //user_image: event.get("image"),

                                                      //user_status: event.get("status"),
                                                      //user_class: "Nursery 2 A",
                                                    )));
                                      }
                                    }

                            }
                          }
                        } 
                        

                        else {
                          setState(() {
                            _isLoading = false;
                          });

                          print('Invalid Username or Password');
                          showErrorDialog("");
                        }*/
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 14, 5, 90),
                              borderRadius: BorderRadius.circular(10)),
                          height: 50,
                          width: _isLoading == true ? 200 : 120,
                          child: Center(
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
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  )
                                : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, color: Colors.white60,),
                                    SizedBox(width: 10,),
                                    Text(
                                    "Log-In",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ],
                                )
                          ))))),
          /*const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Container()),
            const Text(
              "Forgot Password?",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {},
              child: const Text(
                "Reset",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 202, 31, 31)),
              ),
            )
          ]),*/
          const SizedBox(
            height: 20,
          )

          /*AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),*/
        ],
      ),
    );
  }

  /*static CupertinoDialogRoute<void> _dialogBuilder_text(
      BuildContext context, Object arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Error Alert',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('Username Textfield is Empty'),
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
  }*/

  showErrorDialog(String stdname) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Error Alert',
            style: TextStyle(color: Color.fromARGB(255, 182, 32, 21)),
          ),
          content: const Text("Incorrect Username or Password"),
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
              child: const Text(
                'OK',
                style: TextStyle(
                    color: Color.fromARGB(255, 34, 95, 175),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
