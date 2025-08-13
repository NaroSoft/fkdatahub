import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/Authentication/constants.dart';
import 'package:fkdatahub/retaildata/config/responsive.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController myControl = new ScrollController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.newClr1,
        resizeToAvoidBottomInset: true,
        //topImage: "assets/images/main_top.png",
        //bottomImage: "assets/images/login_bottom.png",
        
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/wal2.jpg"),
              fit: BoxFit.cover
              )
            ),
            child: Responsive(
              smallMobile: const MobileLoginScreen(),
              mobile: const MobileLoginScreen(),
              desktop: Center(
                  child: Card(
                elevation: 10,
                child: Container(
                    //padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.black38),
                      //backgroundBlendMode: BlendMode.darken,
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/buydata.jpg",
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.75,
                          fit: BoxFit.cover,
                          //colorFilter: Colors.black12,
                        ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: myControl,
                            child: Column(
                              //mainAxisAlignment:
                              //   MainAxisAlignment.center,
                              //crossAxisAlignment:
                              //   CrossAxisAlignment.center,
                              children: [
                                /*Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(20)),
              child: */
                                const Center(
                                  child: Text.rich(TextSpan(children: [
                                    TextSpan(
                                      text: "M",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 15, 64, 87),
                                          fontSize: 36,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: "y",
                                      style: TextStyle(
                                          fontSize: 32,
                                          color:
                                              Color.fromARGB(255, 15, 64, 87),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: "-",
                                      style: TextStyle(
                                          fontSize: 36,
                                          fontStyle: FontStyle.italic,
                                          color:
                                              Color.fromARGB(255, 15, 64, 87),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: "S",
                                      style: TextStyle(
                                          fontSize: 36,
                                          fontStyle: FontStyle.italic,
                                          color:
                                              Color.fromARGB(255, 15, 64, 87),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: "chool",
                                      style: TextStyle(
                                          fontSize: 32,
                                          color:
                                              Color.fromARGB(255, 15, 64, 87),
                                          fontWeight: FontWeight.bold),
                                    )
                                  ])),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Log into your account",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                    controller: usernameController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    cursorColor: kPrimaryColor,
                                    onSaved: (email) {},
                                    decoration: InputDecoration(
                                      hintText: "Your username",
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 3, right: 10),
                                        child: Container(
                                          height: 43,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                bottomLeft:
                                                    Radius.circular(30)),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.black,
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
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 3, right: 10),
                                        child: Container(
                                          height: 43,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                bottomLeft:
                                                    Radius.circular(30)),
                                            color: Colors.white,
                                          ),
                                          child: const Icon(Icons.lock),
                                        ),
                                      )),
                                ),
                                const SizedBox(height: 30),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Card(
                                        elevation: 10,
                                        child: InkWell(
                                            onTap: () async {
                        FocusScope.of(context).unfocus();

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
                                    isEqualTo: usernameController.text)
                                .get();
                            if (chk.docs.length == 0) {
                              setState(() {
                                _isLoading = false;
                              });

                              print('Invalid Username or Password');
                              showErrorDialog("");
                            } else {
                              FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(chk.docs[0]["worker_id"])
                                  .snapshots()
                                  .listen((event) {
                                //Checking if username exists
                                if (event.exists) {
                                  if (event.get("password") ==
                                      passwordController.text) {
                                    //Checking if username password is the same in database
                                    if (event.get("password") == 'password') {
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
                                                        event.get("full_name"),
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
                                      if (event.get("status") == "Admin" ||
                                          event.get("status") ==
                                              "Assist. Admin") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Dashboard(
                                                      full_name: event
                                                          .get("full_name"),
                                                      user_name:
                                                          event.get("username"),
                                                      user_image:
                                                          event.get("image"),
                                                      user_contact:
                                                          event.get("contact"),
                                                      user_location:
                                                          event.get("location"),
                                                      user_email:
                                                          event.get("email"),
                                                      user_status:
                                                          event.get("status"),
                                                    )));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserDashboard(
                                                      // full_name: event.get("full_name"),
                                                      //user_name: "Frank",
                                                      user_id: event
                                                          .get("worker_id"),
                                                      //user_image: event.get("image"),

                                                      //user_status: event.get("status"),
                                                      //user_class: "Nursery 2 A",
                                                    )));
                                      }
                                    }
                                  }
                                  //when password doesnot match with database
                                  else {
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    print('Invalid Username or Password');
                                    showErrorDialog("");
                                  }
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  print('Invalid Username or Password');
                                  showErrorDialog("");
                                }
                              });
                            }
                          }
                        }
                        //if username textfield EmptyBuilder

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
                                                    /*color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    52,
                                                                    57,
                                                                    121),*/
                                                    color: const Color.fromARGB(
                                                        255, 7, 3, 58),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: 50,
                                                width: _isLoading == true
                                                    ? 200
                                                    : 120,
                                                child: Center(
                                                  child: _isLoading
                                                      ? const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            SizedBox(
                                                                width: 24),
                                                            Text(
                                                              "Please Wait....",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        )
                                                      : const Text(
                                                          "Log-In",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                ))))),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(child: Container()),
                                  const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
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
                                          color:
                                              Color.fromARGB(255, 202, 31, 31)),
                                    ),
                                  )
                                ]),
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
                          ),
                        )),
                      ],
                    )),
              )),
              tablet: const MobileLoginScreen(),
            ),
          ),
        ));
  }

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

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.08,
          right: MediaQuery.of(context).size.width * 0.08,
          top: MediaQuery.of(context).size.width * 0.15,
          bottom: MediaQuery.of(context).size.width * 0.15,
        ),
        child: Card(
            elevation: 10,
            child: Container(
                //padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.black38),
                  //backgroundBlendMode: BlendMode.darken,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/buydata.jpg",
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.fill,
                      //colorFilter: Colors.black12,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                        padding:
                            EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: SingleChildScrollView(
                          child: LoginForm(),
                        ))
                  ],
                )))));
  }
}
