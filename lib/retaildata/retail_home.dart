import 'dart:async';
import 'dart:convert';
import 'package:fkdatahub/retaildata/afaregistration.dart';
import 'package:fkdatahub/retaildata/contactus.dart';
import 'package:fkdatahub/retaildata/payment/payment_page.dart';
import 'package:fkdatahub/retaildata/payment/webpay.dart';
import 'package:fkdatahub/retaildata/statuscheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/retaildata/config/Scrollbar.dart';
import 'package:fkdatahub/retaildata/config/responsive.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'config/ExpandedListAnimationWidget.dart';

class RetailHomePage extends StatefulWidget {
  // final String level, text2;
  //PayRollHomePage({Key? key, required this.level, required this.text2})
  //  : super(key: key);
  static const routeName = '/homePage';
  @override
  _RetailHomePagePageState createState() => _RetailHomePagePageState();
}

class Trip {
  final String stdname;
  final DocumentReference reference;

  Trip.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
          snapshot.data() as Map<String, dynamic>,
          reference: snapshot.reference,
        );

  Trip.fromMap(
    Map<String, dynamic> map, {
    required this.reference,
  }) : stdname = map['student_name'];

  @override
  String toString() => 'Post<$stdname>';
}

class _RetailHomePagePageState extends State<RetailHomePage> {
  String id = "";
  String usernames = "";
  String useremails = "";

  Future getPosts() async {
    //DocumentSnapshot variable = await Firestore.instance.collection('user').document(widget.text).get();
    FirebaseFirestore.instance
        .collection("user")
        .doc(useremails)
        .snapshots()
        .listen((event) {
      setState(() {
        usernames = event.get("user_name");
      });
    });
  }

  navigateToDetail(DocumentSnapshot post) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: post,text2: widget.text2)));
  }

  final TextEditingController _searchController = TextEditingController();
  late Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  var alerttex="";
  bool allowClose = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getUsersPastTripsStreamSnapshots();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var tripSnapshot in _allResults) {
        var pname = Trip.fromSnapshot(tripSnapshot).stdname.toLowerCase();

        if (pname.contains(_searchController.text)) {
          showResults.add(tripSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  Future<void> _refresh() async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RetailHomePage()));
  }

  getUsersPastTripsStreamSnapshots() async {
    //final uid = await Provider.of(context).au
    var data = await FirebaseFirestore.instance.collection('Students').get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
    return "complete";
  }

  var cashout = "", cashin = "";
  void countDocuments() async {
    final myinfo = await FirebaseFirestore.instance
        .collection('Salary_info')
        .doc("payment")
        .get();
    if (myinfo.exists) {}
  }

  @override
  void initState() {
    super.initState();
    //_searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.black, // Color of the refresh indicator
            backgroundColor: AppColors.white, // Background color
            displacement: 40.0, // How far down the indicator appears
            strokeWidth: 3.0, // Thickness of the progress indicator
            triggerMode: RefreshIndicatorTriggerMode.onEdge, // When to trigger
            child: Responsive(
                mobile: const MobileDash(),
                smallMobile: const MobileDash(),
                tablet: const MobileDash(),
                desktop: SafeArea(
                    child: Container(
                  decoration: const BoxDecoration(
                      //image: DecorationImage(
                       //   image: AssetImage("assets/data.jpg"),
                       //   fit: BoxFit.cover),
                      color: AppColors.secondaryBg),
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.35,
                      right: MediaQuery.of(context).size.width * 0.35),
                  child: const MobileDash(),
                ))),
      ),
);
  }
}

class ImagePlaceHolder extends StatelessWidget {
  final String? imagePath;
  const ImagePlaceHolder({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Image.asset(
      imagePath!,
      fit: BoxFit.cover,
    );
  }
}

class MobileDash extends StatefulWidget {
  const MobileDash({
    super.key,
  });
  //const MyDrawer({Key? key}) : super(key: key);

  @override
  _MobileDashState createState() => _MobileDashState();
}

final List<String> imagePaths = [
  'assets/data.jpg',
  'assets/bundle.jpg',
  'assets/joy.png',
  'assets/agent.jpg'
];

late List<Widget> _pages;
int _activePage = 0;
final PageController _pageController = PageController(initialPage: 0);
// ignore: unused_element
Timer? _timer;

class _MobileDashState extends State<MobileDash> {
  var totalstd = -1;
  final bool _isLoading = false;
  List _pricelist = [];
  List amountlist = [];
  int selcapacity = 0;
  var selprice = 0.0, buyprice=0.0, myprofit=0.0;
  var mybalance = "";
  var delnotice = "";
  bool isStrechedDropDown2 = false;
  int groupValue2 = -1;
  String title2 = '-- Choose Bundle --';
  String alerttext="";
  String receivetext="";

  //TextEditing Controller
  TextEditingController rphoneController = TextEditingController();
  TextEditingController alertphoneController = TextEditingController();
  var selbtn="ishare";
  final FocusNode _focusReceive = FocusNode();
  final FocusNode _focusAlert = FocusNode();
  bool allowClose = false;

  void countDocuments() async {
    QuerySnapshot _myDoc1 =
        await FirebaseFirestore.instance.collection("Students").get();
    List<DocumentSnapshot> _myDocCount1 = _myDoc1.docs;
    setState(() {
      totalstd = _myDocCount1.length;
    });
  }

  buyBundleDialog(String netimage, mytitle) {
    return showDialog(
        //barrierColor: Colors.transparent,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(16),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                final screenHeight = MediaQuery.of(context).size.height;
            return ConstrainedBox(
            constraints: BoxConstraints(
              // limit the dialog height so it adjusts when keyboard appears
              maxHeight: screenHeight * 0.9,
              maxWidth: 400, // optional for web
            ),
            child: SingleChildScrollView(
                  child:SizedBox(
              width:  MediaQuery.of(context).size.width * 0.8,
                height:  MediaQuery.of(context).size.height * 0.9,
                child:  Column(
                    // mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        mytitle=="AFA"?"MTN AFA MINUTES":
                        "$mytitle DATA \nBundle",
                        style: TextStyle(
                          fontSize: 23,
                          color: mytitle == "AFA"
                              ? const Color.fromARGB(255, 85, 36, 15)
                              :mytitle == "MTN"
                              ? const Color.fromARGB(255, 85, 78, 15)
                              : mytitle == "TELECEL"
                                  ? const Color.fromARGB(255, 182, 35, 35)
                                  : const Color.fromARGB(255, 19, 28, 156),
                          fontWeight: FontWeight.bold,
                          //decoration: TextDecoration.underline,
                          //decorationThickness: 2
                        ),
                      ),
                    )),
                    InkWell(
                        onTap: () {
                          //if (mounted) {
                          setDialogState(() {
                            title2 = "-- Choose Bundle --";
                            rphoneController.text = "";
                            alertphoneController.text = "";
                            //}
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Card(
                            color: Colors.red,
                            child: SizedBox(
                              height: 35,
                              child: Center(
                                  child: Text(
                                "   X   ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            )))
                  ],
                ),
                //Divider(color: Colors.black),
                //Text(mytext)

                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Card(
                          elevation: 5,
                          child: Image.asset(
                            "assets/$netimage",
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Preferred Bundle",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            //barrierColor: Colors.transparent,
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(content: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setDialogState) {
                                return SizedBox(
              width:  MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.9,
                child:  Column(
                                  //ainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/$netimage"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Divider(
                                          thickness: 2,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(mytitle=="AFA"?"AFA MINUTES OFFERS":"$mytitle DATA OFFER",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color:mytitle == "AFA"?
                                                  const Color.fromARGB(255, 77, 14, 9)
                                                  : mytitle == "MTN"
                                                      ? const Color.fromARGB(
                                                          255, 99, 89, 3)
                                                      : mytitle == "TELECEL"
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 182, 35, 35)
                                                          : const Color
                                                              .fromARGB(
                                                              255, 19, 28, 156),
                                                  fontWeight: FontWeight.bold,
                                                  //decoration: TextDecoration.underline,
                                                  //decorationThickness: 2
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const SizedBox(
            height: 5,
          ),
          mytitle=="AIRTELTIGO"?Card(
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 234, 253),
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(children: [
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              selbtn = "ishare";
                              _pricelist=[];
                              for (int a = 0;
                                            a < amountlist.length;
                                            a++) {
                                          if (amountlist[a]["network_key"] ==
                                              "ishare" && amountlist[a]["price"] !=null ){
                                           // setState(() {
                                         
                                                _pricelist.add({
            'capacity': int.tryParse(amountlist[a]["capacity"]),
            'price': amountlist[a]["price"],
            'buy_price': amountlist[a]["buy_price"],
            'profit': amountlist[a]["profit"],
          });
                                          
                                        //});
                                              }
                                            }
                            });
                            //calarrears();
                          },
                          child: Card(
                            elevation: selbtn == "ishare" ? 10 : 0,
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: selbtn == "ishare"
                                      ? const Color.fromARGB(255, 8, 7, 85)
                                      : const Color.fromARGB(255, 232, 234, 253),
                                  border: selbtn == "ishare"
                                      ? Border.all(
                                          color: const Color.fromARGB(
                                              255, 232, 234, 253),
                                          width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Premium",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selbtn == "ishare"
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              selbtn = "bigtime";
                              _pricelist=[];
                              for (int a = 0;
                                            a < amountlist.length;
                                            a++) {
                                          if (amountlist[a]["network_key"] ==
                                              "bigtime" && amountlist[a]["price"] !=null ){
                                           // setState(() {
                                          _pricelist.add({
            'capacity': amountlist[a]["capacity"],
            'price': amountlist[a]["price"],
            'buy_price': amountlist[a]["buy_price"],
            'profit': amountlist[a]["profit"],
          });
                                        //});
                                              }
                                            }
                            });
                            //getClassDebtors();
                          },
                          child: Card(
                            elevation: selbtn == "bigtime" ? 10 : 0,
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: selbtn == "bigtime"
                                      ? const Color.fromARGB(255, 21, 7, 85)
                                      : const Color.fromARGB(255, 232, 234, 253),
                                  border: selbtn == "bigtime"
                                      ? Border.all(
                                          color: const Color.fromARGB(
                                              255, 232, 234, 253),
                                          width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Big Time",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selbtn == "bigtime"
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ))),
                ]),
              )):const SizedBox(height: 2,),
          const SizedBox(
            height: 15,
          ),
                                    mytitle=="AFA"?
                                    //AFA
                                    Expanded(
                                        child: SizedBox(
                                            child: _pricelist==[]?
                                           const Center(child: CircularProgressIndicator(),)
                                           :
                                            GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        mainAxisSpacing: 10,
                                                        crossAxisSpacing: 10,
                                                        childAspectRatio: 2.3,
                                                        crossAxisCount: 1),
                                                itemCount: _pricelist.length,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () {
                                                        setDialogState(() {
                                                          title2 =
                                                              '${_pricelist[index]["capacity"]}mins for GH₵ ${_pricelist[index]["price"]}';
                                                          selcapacity =
                                                              _pricelist[index]
                                                                  ["capacity"];
                                                          selprice =
                                                              _pricelist[index]
                                                                  ["price"];
                                                          myprofit=_pricelist[index]
                                                                  ["profit"];
                                                          buyprice= _pricelist[index]
                                                                  ["buy_price"];
                                                        });
                                                        //print(title2);
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                        buyBundleDialog(
                                                            netimage, mytitle);
                                                            //showPayInfoDialog();
                                                      },
                                                      child: Card(
                                                        elevation: 5,
                                                        child: Container(
                                                          //height: 100,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black54),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          5))),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Center(
                                                                      child: Container(
                                                                          height: 40,
                                                                          padding: const EdgeInsets.all(5),
                                                                          decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                          child: const Icon(
                                                                            Icons.call,
                                                                            size:
                                                                                30,
                                                                            color:
                                                                                Colors.white,
                                                                          ))),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Text(
                                                                    "${_pricelist[index]["capacity"]} mins",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  "GH₵ ${_pricelist[index]["price"]}",
                                                                  style: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          156,
                                                                          94,
                                                                          0),
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                })))
                                    :Expanded(
                                        child: SizedBox(
                                            child: _pricelist==[]?
                                           const Center(child: CircularProgressIndicator(),)
                                           :
                                            GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        crossAxisCount: 2),
                                                itemCount: _pricelist.length,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () {
                                                        setDialogState(() {
                                                          title2 =
                                                              '${_pricelist[index]["capacity"]}GB for GH₵ ${_pricelist[index]["price"]}';
                                                          selcapacity =
                                                              _pricelist[index]
                                                                  ["capacity"];
                                                          selprice =
                                                              _pricelist[index]
                                                                  ["price"];
                                                          myprofit=_pricelist[index]
                                                                  ["profit"];
                                                          buyprice= _pricelist[index]
                                                                  ["buy_price"];
                                                        });
                                                        //print(title2);
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                        buyBundleDialog(
                                                            netimage, mytitle);
                                                            //showPayInfoDialog();
                                                      },
                                                      child: Card(
                                                        elevation: 5,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black54),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          5))),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Center(
                                                                      child: Container(
                                                                          height: 35,
                                                                          padding: const EdgeInsets.all(5),
                                                                          decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                          child: const Icon(
                                                                            Icons.dns,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.white,
                                                                          ))),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    "${_pricelist[index]["capacity"]}GIG",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  "GH₵${_pricelist[index]["price"]}",
                                                                  style: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          156,
                                                                          94,
                                                                          0),
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                }))),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Card(
                                            color: Color.fromARGB(
                                                255, 196, 30, 18),
                                            child: SizedBox(
                                              height: 40,
                                              child: Center(
                                                  child: Text(
                                                "  Close  ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                            ))),
                                  ],
                                ));
                              }));
                            },
                          );
                        },
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Card(
                              color: mytitle=="AFA"?
                              const Color.fromARGB(255, 233, 140, 10)
                              :mytitle=="MTN"? const Color.fromARGB(255, 243, 253, 104): const Color.fromARGB(255, 253, 104, 104),
                              elevation: 5,
                              child: SizedBox(
                                height: 30,
                                width: 80,
                                child: Center(
                                    child: Text("  Select  > ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: mytitle=="MTN"? Colors.black : Colors.white,
                                            fontSize: 14))),
                              ),
                            )),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Selected Data Package"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBg,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            title2,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recipient",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Enter Phone Number"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      
                      const SizedBox(height: 10.0),
                      TextFormField(

                        // Optional: Remove spaces while typing
          onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              rphoneController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
             final clipboardData = await Clipboard.getData('text/plain');
        final clipboardText = clipboardData?.text ?? '';
        
        // Check if the new text contains clipboard content
        if (clipboardText.isNotEmpty && text.contains(clipboardText)) {
         if(rphoneController.text.length>9){
        String finalnumber = rphoneController.text .substring(rphoneController.text.length - 9);
        setDialogState(() {
          rphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(rphoneController.text.length>10){
              setDialogState(() {
                
                rphoneController.text=receivetext;
              });
            }else{
              setState(() {
                receivetext=rphoneController.text;
              });
              
            }
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: rphoneController,
                        focusNode: _focusReceive,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'eg. 0553123698',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      mytitle=="MTN"? const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Note : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 179, 23, 12),
                              )
                            ),
                            TextSpan(
                              text: "Incorrect, inactive, or Turbonet SIM numbers will result in lost funds. No complaints accepted after 24 hours of Purchase.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              )
                            ),
                          ]
                        )
                      )
                      :
                      mytitle=="AFA"? const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Note : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 179, 23, 12),
                              )
                            ),
                            TextSpan(
                              text: "Customer's number MUST HAVE BEEN REGISTERED ON MTN AFA, and have bought the 10gh AFA bundle before to be eligible for this package. Failure to check before purchasing  and Incorrect number may result in lost funds. No complaints accepted after 24 hours of Purchase.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              )
                            ),
                          ]
                        )
                      )
                      :const Text(""),
                      const SizedBox(height: 20.0),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "SMS Alert & Status Check",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Enter Phone Number"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              alertphoneController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
             final clipboardData = await Clipboard.getData('text/plain');
        final clipboardText = clipboardData?.text ?? '';
        
        // Check if the new text contains clipboard content
        if (clipboardText.isNotEmpty && text.contains(clipboardText)) {
         if(alertphoneController.text.length>9){
        String finalnumber = alertphoneController.text .substring(alertphoneController.text.length - 9);
        setDialogState(() {
          alertphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(alertphoneController.text.length>10){
              setDialogState(() {
                
                alertphoneController.text=alerttext;
              });
            }else{
              setState(() {
                alerttext=alertphoneController.text;
              });
              
            }
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: alertphoneController,
                        focusNode: _focusAlert,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'eg. 0553123698',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                          onTap: () async {
                            if(rphoneController.text.trim().isEmpty){
                              setDialogState(() {
                                FocusScope.of(context).requestFocus(_focusReceive);
                              });
                              
                            }else if(alertphoneController.text.trim().isEmpty){
                              setDialogState(() {
                              FocusScope.of(context).requestFocus(_focusAlert);
                              }); 
                            }else{
                            showDialogProcessing();
                             Future.delayed(const Duration(seconds: 2), () async {
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop();
                              final result ;
                              var orderid =
                                DateFormat("ayyMdhms").format(DateTime.now());
                               // showPayInfoDialog(orderid);
                               if(kIsWeb){
                                result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaystackOnePageApp(
                            amount:selprice,
                            email:"${orderid.toLowerCase()}@gmail.com",
                            reference:orderid,
                            network: mytitle=="AFA"?"afa-talktime":mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':selbtn,
                                receiver: rphoneController.text,
                               capacity : selcapacity,
                                alert_sms:
                                    alertphoneController.text,
                                 buy_price : buyprice,
                                profit : myprofit,
                                date : DateFormat("dd-mm-yyyy")
                                    .format(DateTime.now()),
                                time: DateFormat("h:mm aa")
                                    .format(DateTime.now()),
                                netimage: netimage,
                                mytitle: mytitle,
                          ),
                        ),
                             );
                               }
                               else{
                             result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaystackPaymentPage(
                            amount:selprice,
                            email:"${orderid.toLowerCase()}@gmail.com",
                            reference:orderid,
                            network: mytitle=="AFA"?"afa-talktime":mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':selbtn,
                                receiver: rphoneController.text,
                               capacity : selcapacity,
                                alert_sms:
                                    alertphoneController.text,
                                 buy_price : buyprice,
                                profit : myprofit,
                                date : DateFormat("dd-mm-yyyy")
                                    .format(DateTime.now()),
                                time: DateFormat("h:mm aa")
                                    .format(DateTime.now()),
                                netimage: netimage,
                                mytitle: mytitle,
                          ),
                        ),
                             );
                               }
                             result=="No Payment"?
                             null
                             :
                             setDialogState(() {
                               title2 = "-- Choose Bundle --";
                            rphoneController.text = "";
                            alertphoneController.text = "";
                            getbalance();
                            Navigator.of(context).pop();
                             });

                            });
                            
                            /* var orderid =
                                DateFormat("ayyMdhms").format(DateTime.now());
                             Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                orderlist["network"] = mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':"";
                                orderlist["receiver"] = rphoneController.text;
                                orderlist["reference"] = orderid;
                                orderlist["amount"] = selcapacity;
                                orderlist["price"] = selprice;
                                orderlist["alert_sms"] =
                                    alertphoneController.text;
                                orderlist["date"] = DateFormat("dd-mm-yyyy")
                                    .format(DateTime.now());
                                orderlist["time"] = DateFormat("h:mm aa")
                                    .format(DateTime.now());

                                FirebaseFirestore.instance
                                    .collection('orderlist')
                                    .doc(orderid)
                                    .set(orderlist)
                                    .whenComplete(() {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  getbalance();
                                  showSuccessDialog1(netimage, orderid);
                                  
                                });*/
                                
                                //print(orderid);
                               /* var orderid =
                                DateFormat("ayyMdhms").format(DateTime.now());
                           const String authToken =
                                "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605"; // Replace with your API key

                            // 1. Define your endpoint and headers (like in Postman's Headers tab)
                            const String apiUrl =
                                'https://test.gdsonline.app/api/v1/placeOrder';
                            final Map<String, String> headers = {
                              'Content-Type': 'application/json',
                              'Authorization':
                                  'Bearer $authToken', // Replace with actual token
                              'Accept': 'application/json',
                            };

                            // 2. Create request body (like in Postman's Body tab)
                            final Map<String, dynamic> requestBody = {
                              "network": mytitle=="AFA"?"afa-talktime": mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':selbtn,
                              "reference": orderid,
                              "receiver": rphoneController.text,
                              "amount": selcapacity
                            };

                            try {
                              // 3. Make the POST request (like clicking "Send" in Postman)
                              final response = await http.post(
                                Uri.parse(apiUrl),
                                headers: headers,
                                body: jsonEncode(requestBody),
                              );

                              // 4. Handle the response
                              if (response.statusCode == 200) {
                                // Successful request
                                final responseData = jsonDecode(response.body);
                                if (kDebugMode) {
                                  print('Success! Response: $responseData');
                                }

                                Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                orderlist["network"] = mytitle=="AFA"?"afa-talktime": mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':selbtn;
                                orderlist["receiver"] = rphoneController.text;
                                orderlist["reference"] = orderid;
                                orderlist["amount"] = selcapacity;
                                orderlist["price"] = selprice;
                                orderlist["alert_sms"] =
                                    alertphoneController.text;
                                orderlist["buy_price"] = buyprice;
                                orderlist["profit"] = myprofit;
                                orderlist["status"] = "pending";
                                orderlist["walletstatus"] = "available";
                                orderlist["full_date"] = DateFormat("EEE, MMM d, yyyy")
                                    .format(DateTime.now());
                                orderlist["date"] = DateFormat("dd-MM-yyyy")
                                    .format(DateTime.now());
                                orderlist["day"] = num.tryParse(DateFormat("d")
                                    .format(DateTime.now()));
                                orderlist["month_no"] = num.tryParse(DateFormat("M")
                                    .format(DateTime.now()));
                                orderlist["year"] = DateFormat("yyyy")
                                    .format(DateTime.now());
                                orderlist["time"] = DateFormat("h:mm aa")
                                    .format(DateTime.now());
                                orderlist["timestamp"] = FieldValue.serverTimestamp();


                                FirebaseFirestore.instance
                                    .collection('orderlist')
                                    .doc(orderid)
                                    .set(orderlist)
                                    .whenComplete(() {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  getbalance();
                                  showSuccessDialog1(netimage, orderid,mytitle);
                                  
                                });

                                // You might want to return the data or update your UI here
                                return responseData;
                              } else {
                                // Error handling
                                if (kDebugMode) {
                                  print(
                                      'Request failed with status: ${response.statusCode}');
                                }
                                if (kDebugMode) {
                                  print('Response body: ${response.body}');
                                }
                                //throw Exception('Failed to place order');
                              }
                            } catch (e) {
                              // Network or other errors
                              if (kDebugMode) {
                                print('Error making POST request: $e');
                              }
                              //throw Exception('Network error: $e');
                            }*/
                            //showSuccessDialog1(netimage, "INV123",mytitle);
                            }
                          },
                          child: Card(
                              color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 253, 229, 11)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 182, 35, 35)
                                      : const Color.fromARGB(255, 19, 28, 156),
                              elevation: 5,
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: _isLoading
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Colors.black54,
                                            ),
                                            SizedBox(width: 24),
                                            Text(
                                              "Please Wait....",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                          ],
                                        )
                                      : Text("Buy Now",
                                          style: TextStyle(
                                              color: mytitle == "MTN" || mytitle=="AFA"
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ))),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                )),
              ],
            ))));
          }));
        });
  }
  

  showSuccessDialog(String msg) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Icon(
              Icons.save_alt_rounded,
              color: Color.fromARGB(255, 3, 94, 6),
              size: 50,
            ),
            content: SizedBox(
              width:  MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
              children: [
                Text(
                  msg,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 36, 2),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                )
              ],
            )),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  //Navigator.pop(context);
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
        });
  }

  showErrorDialog(String msg) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Icon(
              Icons.error_outline,
              color: Color.fromARGB(255, 94, 24, 3),
              size: 50,
            ),
            content: SizedBox(
              width:  MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
              children: [
                Text(
                  msg,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 36, 2),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                )
              ],
            )),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  //Navigator.pop(context);
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
        });
  }

  showPayInfoDialog(String orderid) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            
            content: Column(
              children: [
                Container(
            height: 130,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/celeb.gif'), fit: BoxFit.fill)),
          ),
          const SizedBox(height: 10,),
                const Text(
                  "Patment Info",
                  style: TextStyle(
                      fontSize: 28,
                      color: Color.fromARGB(255, 2, 115, 8),
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15,),


                Card(
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      const Text(
                  "Amount",
                  style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(195, 0, 36, 2),
                      fontStyle: FontStyle.italic,
                      //fontWeight: FontWeight.bold
                      ),
                ),
                SelectableText(
                  "GH₵ $selprice",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 4, 103, 9),
                      //fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),
                    ],
                  ),
                ),),
                
              
                 const SizedBox(height: 15,),
               
                  const Text(
                  "Send amount payable to :  ",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                      //fontWeight: FontWeight.bold
                      ),
                ),
                const SelectableText(
                  "0553123698",
                  style:TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 96, 3, 89),
                      //fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20,),
                 const Text(
                  "Account Name :  ",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                      //fontWeight: FontWeight.bold
                      ),
                ),
                const SelectableText(
                  "Frank Adjei",
                  style:TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      //fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),

               const SizedBox(height: 10,),

                const Text(
                  "Use Order ID as reference :  ",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                      //fontWeight: FontWeight.bold
                      ),
                ),
                SelectableText(
                  orderid,
                  style:const TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 169, 3, 3),
                      //fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20,),
                 const Divider(thickness: 2,color: Colors.black38,),
                const Text(
                  "Click on Finish after payment from Momo and wait for payment verification and processing of data order. Thank You",
                  style:TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      //fontWeight: FontWeight.bold
                      ),
                )
                 
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  setState(() {
                    title2="-- Choose Bundle --";
                    rphoneController.text="";
                    alertphoneController.text="";
                  });(() {
                    
                  });
                  Navigator.pop(context);
                  //Navigator.pop(context);
                  //Navigator.pop(context);
                },
                child: const Text(
                  'Finish',
                  style: TextStyle(
                      color: Color.fromARGB(255, 34, 95, 175),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  comingSoonDialog(String msg) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Icon(
              Icons.message,
              color: Color.fromARGB(255, 170, 9, 9),
              size: 50,
            ),
            content: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  msg,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 0, 36, 2),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            actions: <Widget>[
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
        });
  }

  showSuccessDialog1(String netimage, orderid, mytitle) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
              return SizedBox(
              width:  MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                children: [
                  Card(
                  ///  color: mytitle == "MTN"
                      //            ? const Color.fromARGB(255, 253, 229, 11)
                             //     : mytitle == "TELECEL"
                             //         ? const Color.fromARGB(255, 182, 35, 35)
                              //        : const Color.fromARGB(255, 13, 19, 111),
                    elevation: 5,
                    child: Container(
                     //alignment: Alignment.center,
                     padding: const EdgeInsets.only(left:10, right: 10, top: 5, bottom: 5),
                    height: 80,
                    decoration: BoxDecoration(
                      color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 253, 229, 11)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 182, 35, 35)
                                      : const Color.fromARGB(255, 13, 19, 111),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                     Text(mytitle=="AFA"?"AFA MINUTES":
                    "$mytitle Order",
                    style: TextStyle(
                        fontSize: 20,
                        color:   mytitle == "MTN" || mytitle=="AFA"
                                  ? Colors.black : Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Placed Successfully.",
                    style: TextStyle(
                        fontSize: 20,
                        color:   mytitle == "MTN" || mytitle=="AFA"
                                  ? Colors.black : Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  )
                      ]
                  ),
                  )),
                   
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Card(
                      elevation: 5,
                      child: Center(
                        child: Image.asset(
                          "assets/celeb.gif",
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  /* Center(
                  child: Card(
                    elevation: 5,
                    child: Image.asset(
                      "assets/$netimage",
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),*/
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 3,
                    height: 2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Order ID : ",
                        style: TextStyle(
                          fontSize: 18,
                          //fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text: orderid,
                        style: TextStyle(
                          fontSize: 20,
                          color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 111, 6, 6)
                                      : const Color.fromARGB(255, 20, 3, 82),
                          fontWeight: FontWeight.bold,
                        ))
                  ])),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Receiver : ",
                        style: TextStyle(
                          fontSize: 18,
                          //fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text: rphoneController.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 111, 6, 6)
                                      : const Color.fromARGB(255, 20, 3, 82),
                        ))
                  ])),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Capacity : ",
                        style: TextStyle(
                          fontSize: 18,
                          //fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text:  mytitle=="AFA"?"$selcapacity mins":"$selcapacity GIG",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 111, 6, 6)
                                      : const Color.fromARGB(255, 20, 3, 82),
                        ))
                  ])),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Price : ",
                        style: TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text: "GH₵ $selprice",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mytitle == "MTN" || mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 111, 6, 6)
                                      : const Color.fromARGB(255, 20, 3, 82),
                        ))
                  ]))
                ],
              ));
            }),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  setState(() {
                    title2 = "-- Choose Bundle --";
                    rphoneController.text = "";
                    alertphoneController.text = "";
                    //}
                  });
                  //Navigator.pop(context);
                  Navigator.pop(context);
                  //Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                      color: Color.fromARGB(255, 175, 43, 34),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.page == imagePaths.length - 1) {
        //check if its on last page
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInCirc);
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInSine);
      }
    });
  }

  //Get Balance
  void getbalance() async {
    mybalance = "";
    delnotice = "";
    const String authToken =
        "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
    //final dio = Dio();
    /*try {
      // var request = http.Request('GET', Uri.parse('http://127.0.0.1:8000/api/v1/walletBalance'));
      //Map<String, dynamic> getbal = [];
      final response = await http.get(
        Uri.parse('https://test.gdsonline.app/api/v1/walletBalance'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> getbal = jsonDecode(response.body);

      //final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // 200 indicates success
        //String rawbalnce = getbal["data"]["walletBalance"].toString();
        //String procebalance = rawbalnce.substring(16, rawbalnce.length - 1);
        //String finalbalance = procebalance.substring(0, rawbalnce.length- 1);
        //setState(() {
         // mybalance = procebalance;
        //});
        //balance = procebalance;
        //showSuccessDialog('Response data: ${getbal["data"]}');
        print("Response Balance: ${getbal['data']["walletBalance"]}");
      } else {
        showSuccessDialog('Code Error: ${response.statusCode}');
        //throw Exception('Code Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }*/
    DateTime timenow = DateTime.now();
    DateTime spectime1 = DateTime(timenow.year, timenow.month, timenow.day, 7,10);
    DateTime spectime2 = DateTime(timenow.year, timenow.month, timenow.day, 20,55);
    if(timenow.hour<spectime1.hour || (timenow.hour==spectime1.hour && timenow.minute<spectime1.minute)){
      setState(() {
      delnotice="We have Closes for the day. We will resume operations at 7:10 AM.";
    });
    }
    if(timenow.hour>spectime2.hour || (timenow.hour==spectime2.hour && timenow.minute>spectime2.minute)){
      setState(() {
      delnotice="We have Closes for the day. We will resume operations at 7:10 AM.";
    });
    }
    else{
    try {
      // var request = http.Request('GET', Uri.parse('http://127.0.0.1:8000/api/v1/walletBalance'));
      //Map<String, dynamic> getbal = [];
      final response = await http.get(
        Uri.parse('https://test.gdsonline.app/api/v1/deliveryNotice'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> getnotice = jsonDecode(response.body);

      //final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // 200 indicates success
        //String rawnotice = getnotice["data"]["message"].toString();
        //String procenotice = rawnotice.substring(10, rawnotice.length - 1);
        setState(() {
          delnotice = getnotice["data"]["message"].toString();
        });
        //balance = procebalance;
        //showSuccessDialog('Response data: ${getbal["data"]}');
        //print("Response Balance: ${data['reference']}");
      
      } else {
        showErrorDialog('No Internet Connection. Check your networks connectivity and refresh');
        //throw Exception('Code Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = List.generate(
        imagePaths.length,
        (index) => ImagePlaceHolder(
              imagePath: imagePaths[index],
            ));
    startTimer();
    getbalance();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          toolbarHeight: 120,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
               Row(children: [
                Card(
                  elevation: 5,
                  child: SizedBox(
                  height: 80,
                  width: 100,
                  child: Image.asset("assets/FKDataHub.png",
                  fit: BoxFit.fill,
                  )),
                ),
                const SizedBox(width: 10,),
                Expanded(child: Container(
                  child: Column(
                    children: [
                      const Text(
                "Buy Data Bundle",
                style: TextStyle(
                    color: AppColors.newClr1,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5,),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                          DateFormat("EEEE").format(DateTime.now()),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 29, 39, 231),
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ),
              ),
              const SizedBox(
                          height: 5,
                        ),
                        Align(
                alignment: Alignment.centerRight,
                child:  Text(
                          DateFormat("MMM d, yyyy").format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        )),
                    ],
                  ),
                ))
                
              ],),
              
              /*Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          DateFormat("EEEE").format(DateTime.now()),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 77, 234, 255),
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          DateFormat("MMM d, yyyy").format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    Card(
                        color: AppColors.newClr1,
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 15, right: 15),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.lightBlueAccent, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Wallet",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  )
                                ],
                              ),
                              mybalance == ""
                                  ? const CircularProgressIndicator(
                                      color: Colors.white60,
                                    )
                                  : Center(
                                      child: Text(
                                      "GH₵ $mybalance",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                              255, 161, 255, 124),
                                          fontWeight: FontWeight.bold),
                                    )),
                            ],
                          ),
                        )),
                  ],
                ),
              ),*/
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        body:  LayoutBuilder(
    builder: (context, _) {
      final bottom = MediaQuery.of(context).viewInsets.bottom;
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom), // pushes content above keyboard
        child: SafeArea(
            child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                    /*image: DecorationImage(
                        image: const AssetImage("assets/walp1.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.05), BlendMode.darken))*/
                            ),
                //padding: const EdgeInsets.only(left: 15, right: 15),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(children: [
                 const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryBg
                    ),
                    child: Column(children: [
                    
                 const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text("Experience Limitless Connectivity with Our Irresistibly Affordable Data Bundles!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color.fromARGB(255, 119, 25, 129)
                  ),
                  )),
                  const SizedBox(height: 10,),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text("Unlock Seamless Connectivity with FKDataHub – Ghana's Ultimate Hub for Mobile Data Bundles! "
                  "Discover the Best Deals from MTN, Telecel, and AirtelTigo, All in One Powerful Platform!",
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black
                    )),
                  ),

                  const SizedBox(height: 15,),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: const Center(child: Text("MTN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                        ),),),

                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: const Center(child: Text("Telecel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                        ),),),
                        Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 40, 127),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: const Center(child: Text("AirtelTigo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                        ),),)
                  ],)),

                  const SizedBox(height: 15,)
                  ],),),
                  /*Card(
                    elevation: 5,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green, width: 0.5)),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.timelapse_outlined,
                              color: Color.fromARGB(255, 27, 117, 30),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 3,
                                ),
                                Center(
                                  child: Text(
                                    "Welcome to FKDATAHub",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 27, 117, 30),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "System Active . Place Your Orders",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),*/
                  
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2.7,
                        child: PageView.builder(
                            controller: _pageController,
                            itemCount: imagePaths.length,
                            onPageChanged: (value) {
                              setState(() {
                                _activePage = value;
                              });
                            },
                            itemBuilder: (context, index) {
                              //return image widget
                              return _pages[index];
                            }),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        left: 0,
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                                _pages.length,
                                (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: InkWell(
                                        onTap: () {
                                          _pageController.animateToPage(index,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeIn);
                                        },
                                        child: CircleAvatar(
                                          radius: 5,
                                          backgroundColor: _activePage == index
                                              ? const Color.fromARGB(
                                                  255, 0, 255, 242)
                                              : Colors.grey,
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Card(
                    elevation: 5,
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 116, 6, 57),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                        ),
                        //border: Border.all(
                        //  color: AppColors.newClr1,
                        // width: 0.5
                        //)
                      ),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                        ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notification_important,
                              size: 30,
                              color: Color.fromARGB(255, 116, 6, 57),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            delnotice == ""
                                ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 141, 9, 71),
                                  )
                                : Expanded(
                                    child: Center(
                                        child: Text(
                                    delnotice,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 175, 22, 94),
                                        fontWeight: FontWeight.bold),
                                  ))),
                          ],
                        ),
                      ),
                    ),
                  )),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Card(
                    elevation: 5,
                    child: Container(
                        //height: 70,
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)
                        ),
                        ),
                        child: Column(
                          children: [
                           Container(
                              decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 254, 247, 178)
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                              Icons.error_outline_outlined,
                              size: 30,
                              color: Color.fromARGB(255, 116, 90, 6),
                            ),
                            SizedBox(width: 10,),
                            Text("Important Service Notice",
                            style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 147, 116, 24),
                          fontSize: 18,
                        ),
                            )
                                ],
                              )),
                          const SizedBox(height: 10,),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                              decoration: const BoxDecoration(
                              color: Colors.white,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                              Icons.error_outline_outlined,
                              size: 20,
                              color: Color.fromARGB(255, 116, 90, 6),
                            ),
                            SizedBox(width: 10,),
                            Text("Please Note Before Proceeding:",
                            style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                            )
                                ],
                              )),
                              const SizedBox(height: 5,),
                         const Padding(
                            padding: EdgeInsets.only(left: 20, right: 5),
                            child: Text("• This is not an instant service. Data delivery times vary between customers.\n"
                               "• We are working diligently to process all orders, but there may be delays.\n"
                              "•  If you need immediate data for urgent matters, please dial *138# on your MTN line instead.\n"
                              "•  Once ordered, please be patient as we process your request.\n"
                              "•  For instant bundles, this service is not suitable.",
                              style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,)
                              )),
                              const SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              decoration: const BoxDecoration(color: Color.fromARGB(255, 216, 231, 255)),
                            child: const Center(child: Text("We truly appreciate your patience and understanding.",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 92, 114, 195)),
                            ),),
                          )),
                          const SizedBox(height: 10,),
                          ],
                        ),
                      ),
                  )),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
  setState(() {
    amountlist = [];
    _pricelist = [];
  });
  showDialogLoading();
  
  const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
  
  // Retry function implementation
  Future<http.Response> retryRequest() async {
    int maxRetries = 3;
    Duration delay = const Duration(seconds: 1);
    int attempt = 0;
    
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('https://test.gdsonline.app/api/v1/allProducts'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));  // Added timeout
        
        if (response.statusCode == 200) {
          return response;
        }
       // throw Exception('Request failed with status: ${response.statusCode}');
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
        await Future.delayed(delay * attempt); // Exponential backoff
      }
    }
  }

  try {
    List<dynamic> rawprices = [];
    final response = await retryRequest(); // Using the retry function
    rawprices = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (int a = 0; a < rawprices.length; a++) {
        if (rawprices[a]["network_key"] == "mtn" && rawprices[a]["price"] != null) {
          var getcap = rawprices[a]["capacity"];
          var getamount = double.tryParse(rawprices[a]["price"]);
          
          double finalamount,profit;
          if (int.tryParse(getcap)! < 20) {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.15;
          } else if (int.tryParse(getcap)! > 19 && int.tryParse(getcap)! < 30) {
            profit=getamount! * 0.115;
            finalamount = getamount + getamount * 0.115;
          } else if (int.tryParse(getcap)! > 29 && int.tryParse(getcap)! < 40) {
            profit=getamount! * 0.085;
            finalamount = getamount + getamount * 0.085;
          } else {
            profit=getamount! * 0.06;
            finalamount = getamount! + getamount * 0.06;
          }
          
          amountlist.add({
            'capacity': int.tryParse(rawprices[a]["capacity"]),
            'price': finalamount.roundToDouble(),
            'buy_price':double.tryParse(rawprices[a]["price"]),
            'profit': profit.roundToDouble(),
          });
          
          if (kDebugMode) {
            print(amountlist);
          }
        }
      }

      setState(() {
        _pricelist = amountlist.toList();
      });

      if (kDebugMode) {
        print(_pricelist.length.toString());
      }
      Navigator.of(context).pop();
      buyBundleDialog("mtn1.png", "MTN");
    } else {
      throw showSuccessDialog('Code Error: ${response.statusCode}');
      //throw Exception('Code Error: ${response.statusCode}');
    }
  } catch (e) {
    Navigator.of(context).pop(); // Ensure loading dialog is dismissed
    showSuccessDialog('Failed after retries: $e');
    print("Error: $e");
  }
},
                                  child: Card(
                                    color: AppColors.white,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppColors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/mtn1.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            fit: BoxFit.fill,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "   Buy Now",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
  setState(() {
    amountlist = [];
    _pricelist = [];
  });
  showDialogLoading();
  
  const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";

  // Retry function with exponential backoff
  Future<http.Response> retryHttpRequest() async {
    int maxRetries = 3;
    Duration initialDelay = const Duration(seconds: 1);
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('https://test.gdsonline.app/api/v1/allProducts'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode >= 500) {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        } else {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
        await Future.delayed(initialDelay * attempt);
      }
    }
    throw showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
  }

  try {
    final response = await retryHttpRequest();
    final rawprices = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Process ishare and bigtime products
      for (int a = 0; a < rawprices.length; a++) {
        if (rawprices[a]["network_key"] == "ishare" || rawprices[a]["network_key"] == "bigtime" && 
            rawprices[a]["price"] != null) {
          
          var getcap = rawprices[a]["capacity"];
          var getamount = double.tryParse(rawprices[a]["price"]);
          
          // Calculate final amount based on capacity ranges
          double finalamount,profit;
          if (int.tryParse(getcap)! < 20) {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.15;
          } else if (int.tryParse(getcap)! < 30) {
            profit=getamount! * 0.115;
            finalamount = getamount + getamount * 0.115;
          } else if (int.tryParse(getcap)! < 40) {
            profit=getamount! * 0.13;
            finalamount = getamount + getamount * 0.13;
          } else if (int.tryParse(getcap)! < 50) {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.1;
          } else {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.18;
          }

          amountlist.add({
            'capacity': int.tryParse(rawprices[a]["capacity"]),
            'price': finalamount.roundToDouble(),
            'buy_price':double.tryParse(rawprices[a]["price"]),
            'network_key' : rawprices[a]["network_key"],
            'profit': profit.roundToDouble(),
          });
          
          if (kDebugMode) {
            print(amountlist);
          }
        }
      }

      // Filter for ishare products only
      _pricelist = amountlist.where((item) => item["network_key"] == "ishare").toList();

      if (kDebugMode) {
        print(_pricelist.length.toString());
      }
      
      Navigator.of(context).pop();
      setState(() {
        selbtn = "ishare";
      }); 
      buyBundleDialog("airtel2.jpeg", "AIRTELTIGO");
    } else {
      Navigator.of(context).pop();
      showSuccessDialog('Code Error: ${response.statusCode}');
    }
  } catch (e) {
    Navigator.of(context).pop();
    showSuccessDialog('Failed to load data: ${e.toString()}');
    print("Error: $e");
  }
},
                                  child: Card(
                                    color:
                                        const Color.fromARGB(255, 9, 82, 141),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(
                                            255, 9, 82, 141),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/airtel2.jpeg',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "   Buy Now",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white54,
                                                    ),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))),
                        ],
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
  setState(() {
    amountlist = [];
    _pricelist = [];
  });
  showDialogLoading();
  
  const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";

  // Retry function with exponential backoff
  Future<http.Response> retryHttpRequest() async {
    int maxRetries = 3;
    Duration initialDelay = const Duration(seconds: 1);
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('https://test.gdsonline.app/api/v1/allProducts'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode >= 500) {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        } else {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
        await Future.delayed(initialDelay * attempt);
      }
    }
    throw showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
  }

  try {
    final response = await retryHttpRequest();
    final rawprices = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Process telecel products
      for (int a = 0; a < rawprices.length; a++) {
        if (rawprices[a]["network_key"] == "telecel" && rawprices[a]["price"] != null) {
          var getcap = rawprices[a]["capacity"];
          var getamount = double.tryParse(rawprices[a]["price"]);

         
          // Calculate final amount based on capacity ranges
          double finalamount,profit;
          if (int.tryParse(getcap)! < 6) {
            profit=getamount! * 0.18;
            finalamount = getamount + getamount * 0.18;
          } else if (int.tryParse(getcap)! < 11) {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.15;
          } else if (int.tryParse(getcap)! < 20) {
            profit=getamount! * 0.15;
            finalamount = getamount + getamount * 0.15; // Added missing range 11-19
          } else if (int.tryParse(getcap)! < 50) {
            profit=getamount! * 0.12;
            finalamount = getamount + getamount * 0.12;
          } else {
            profit=getamount! * 0.025;
            finalamount = getamount + getamount * 0.08;
          }

          amountlist.add({
            'capacity': int.tryParse(rawprices[a]["capacity"]),
            'price': finalamount.roundToDouble(),
            'buy_price':double.tryParse(rawprices[a]["price"]),
            'network_key' : rawprices[a]["network_key"],
            'profit': profit.roundToDouble(),
          });

          if (kDebugMode) {
            print(amountlist);
          }
        }
      }

      setState(() {
        _pricelist = amountlist.toList();
      });

      if (kDebugMode) {
        print(_pricelist.length.toString());
      }
      
      Navigator.of(context).pop();
      buyBundleDialog("telecel1.png", "TELECEL");
    } else {
      Navigator.of(context).pop();
      showSuccessDialog('Code Error: ${response.statusCode}');
    }
  } catch (e) {
    Navigator.of(context).pop();
    showSuccessDialog('Failed to load data: ${e.toString()}');
    print("Error: $e");
  }
},
                                  child: Card(
                                    color: Colors.red,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.red,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/telecel1.png',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "   Buy Now",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white54,
                                                    ),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: InkWell(
                                  //onTap: () => comingSoonDialog(
                                    //  "Agent Portal Closed. Opening Soon!!!"),
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: ((context)=>const RegistrationScreen())));
                                    },
                                  child: Card(
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/mtnafa.jpeg',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "  Register Now",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                        ],
                      )),

                      const SizedBox(height: 20),

                      Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
  setState(() {
    amountlist = [];
    _pricelist = [];
  });
  showDialogLoading();
  
  const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";

  // Retry function with exponential backoff
  Future<http.Response> retryHttpRequest() async {
    int maxRetries = 3;
    Duration initialDelay = const Duration(seconds: 1);
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('https://test.gdsonline.app/api/v1/allProducts'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode >= 500) {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        } else {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
        }
        await Future.delayed(initialDelay * attempt);
      }
    }
    throw showErrorDialog('No Internet Connection. Check your networks connectivity and Retry');
  }

  try {
    final response = await retryHttpRequest();
    final rawprices = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Process telecel products
      for (int a = 0; a < rawprices.length; a++) {
        if (rawprices[a]["network_key"] == "afa-talktime" && rawprices[a]["price"] != null) {
          var getcap = rawprices[a]["capacity"];
          var getamount = double.tryParse(rawprices[a]["price"]);
          
          // Calculate final amount based on capacity ranges
          double finalamount,profit;
          if (int.tryParse(getcap)! < 300) {
            profit=getamount! * 0.5;
            finalamount = getamount + getamount *  0.5;
          } else if (int.tryParse(getcap)! < 600) {
            profit=getamount! * 0.5;
            finalamount = getamount + getamount * 0.5;
          } else if (int.tryParse(getcap)! < 900) {
            profit=getamount! * 0.5;
            finalamount = getamount + getamount *  0.5; // Added missing range 11-19
          }else {
            profit=getamount! * 0.45;
            finalamount = getamount + getamount *  0.45;
          }

          amountlist.add({
            'capacity': int.tryParse(rawprices[a]["capacity"]),
            'price': finalamount.roundToDouble(),
            'buy_price':double.tryParse(rawprices[a]["price"]),
            'network_key' : rawprices[a]["network_key"],
            'profit': profit.roundToDouble(),
          });

          if (kDebugMode) {
            print(amountlist);
          }
        }
      }

      setState(() {
        _pricelist = amountlist.toList();
      });

      if (kDebugMode) {
        print(_pricelist.length.toString());
      }
      
      Navigator.of(context).pop();
      buyBundleDialog("speak.png", "AFA");
    } else {
      Navigator.of(context).pop();
      //showSuccessDialog('Code Error: ${response.statusCode}');
      showSuccessDialog('No Internet Connection. Check your networks connectivity and Retry');
    }
  } catch (e) {
    Navigator.of(context).pop();
    showSuccessDialog('No Internet Connection. Check your networks connectivity and Retry');
    print("Error: $e");
  }
},
                                  child: Card(
                                    color: Colors.yellow,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.yellow,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/speak.png',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "   AFA Minutes",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: InkWell(
                                  onTap: () => comingSoonDialog(
                                      "Shop not Ready. Opening Soon!!!"),
                                   // onTap: (){
                                     // Navigator.of(context).push(MaterialPageRoute(builder: ((context)=>const RegistrationScreen())));
                                    //},
                                  child: Card(
                                    color: Colors.purple,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.purple,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/shop.png',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "  Shop Now",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white54,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                        ],
                      )),

                      const SizedBox(height: 20),

                      Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1,
                        right: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: Row(children: [
                       
                          Expanded(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const STATUSCHECK()));
                                  },
                                  child: Card(
                                    color: Colors.orange,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.orangeAccent,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/order.jpg',
                                            fit: BoxFit.fitWidth,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "  Check Now",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),

                                  const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: InkWell(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ContactUsPage()));
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 10,
                                    child: Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Image.asset(
                                            'assets/support.png',
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          )),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                                height: 30,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "  Contact Us",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                      ],)),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 33, 60, 118),
                    ),
                    child: const Column(
                      children: [
                        SizedBox(height: 10,),
                         Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("About US",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                        )),
                        SizedBox(height: 10,),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Our focus is on delivering premium solutions and exceptional service to ensure our customers' success.",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                        ),

                        SizedBox(height: 15,),

                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Contact Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                        )),
                        SizedBox(height: 10,),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 10),
                          child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Accra, Ghana\n"
                          "Phone: +233 55 312 3698\n"
                          "Email: adjeifrank002@gmail.com",
                        style: TextStyle(
                          color: Color.fromARGB(255, 198, 209, 255),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ))),
                        ),
                        SizedBox(height: 10,),
                        Divider(color: Colors.white60,),
                        Center(child: Text("© 2025 FKDataHUB. All rights reserved.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        )
                        ),),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                 
                ])
                )
                )
                )
                );
  })
                );
  }

  showDialogConfirm() {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: SafeArea(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Lottie.asset('assets/loading_gif.json',
                        height: 160, width: 160)),
                const Text(
                  'Please Wait .....',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )),
          );
        });
  }

  showDialogProcessing() {
    return showDialog(
        context: context,
        //barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              content: Container(
            height: 80,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/process.gif'), fit: BoxFit.fill)),
          ));
        });
  }

  showDialogLoading() {
    return showDialog(
        context: context,
        //barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              content: Container(
            height: 60,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/wait.gif'), fit: BoxFit.fill)),
          ));
        });
  }
}
