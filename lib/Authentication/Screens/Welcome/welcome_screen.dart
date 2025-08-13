import 'dart:async';

import 'package:fkdatahub/Authentication/Screens/Login/login_screen_1.dart';
import 'package:fkdatahub/Authentication/components/background_1.dart';
import 'package:fkdatahub/retaildata/config/responsive.dart';
import 'package:flutter/material.dart';
import 'components/welcome_image.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
 double _progress = 0;

  void startTimer() {
    new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(
              () {
                if (_progress == 10) {
                  timer.cancel();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  _progress += 2;
                }
              },
            ));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _progress = 0;
    });
    startTimer();
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            smallMobile: MobileWelcomeScreen(),
            desktop: Center(
                child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "WELCOME TO MY-SCHOOL",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 2, 3, 63),
                      fontSize: 40),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 8,
                      child: Image.asset(
                        "assets/gif/welcome.gif",
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.6,
                        //color: Colors.blueGrey,
                        //fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                //SizedBox(height: defaultPadding * 2),
              ],
            )),
            mobile: MobileWelcomeScreen(),
            tablet: MobileWelcomeScreen(),
          ),
        ),
      ),
    );
  }
}

class MobileWelcomeScreen extends StatefulWidget {
  @override
  _MobileWelcomeScreenState createState() => _MobileWelcomeScreenState();
}

class _MobileWelcomeScreenState extends State<MobileWelcomeScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;

  void startTimer() {
    new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(
              () {
                if (_progress == 10) {
                  timer.cancel();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  _progress += 2;
                }
              },
            ));
  }

  @override
  void initState() {
    super.initState();
    //setState(() {
      //_progress = 0;
    //});
    //startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        SizedBox(
          height: 30,
        ),

        /*Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                width: 60,
                margin: EdgeInsets.only(bottom: 40.0),
                child: Image.asset('assets/gif/loading_logo.gif'),
              ),
            )
        Row(
          children: const [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),*/
      ],
    );
  }
}
