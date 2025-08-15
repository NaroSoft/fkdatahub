import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/retaildata/payment/payment_page.dart';
import 'package:fkdatahub/retaildata/payment/webpay.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Buydata extends StatefulWidget {
   final String netimage, mytitle;
   final List pricelist;
  Buydata({Key? key, required this.netimage, required this.mytitle, required this.pricelist})
   : super(key: key);

  @override
  _BuydataState createState() => _BuydataState();
}

class _BuydataState extends State<Buydata> {
 

    var totalstd = -1;
  final bool _isLoading = false;
  List _pricelist = [];
 // List widget.pricelist = [];
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pricelist=widget.pricelist;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBg,
      appBar: AppBar(
        title: const Text('Buy Bundle',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          
        ),
        ),
        foregroundColor: AppColors.newClr1,
        centerTitle: true,
        backgroundColor: AppColors.secondaryBg,
        elevation: 5,
        
      ),
     
      body: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1, right:MediaQuery.of(context).size.width * 0.1, top: 8.0, bottom: 8.0),
                child:  Column(
                    // mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.mytitle=="AFA"?"MTN AFA MINUTES":
                        "${widget.mytitle} Non-Expiry Bundles",
                        style: TextStyle(
                          fontSize: 23,
                          color: widget.mytitle == "AFA"
                              ? const Color.fromARGB(255, 85, 36, 15)
                              :widget.mytitle == "MTN"
                              ? const Color.fromARGB(255, 85, 78, 15)
                              : widget.mytitle == "TELECEL"
                                  ? const Color.fromARGB(255, 182, 35, 35)
                                  : const Color.fromARGB(255, 19, 28, 156),
                          fontWeight: FontWeight.bold,
                          //decoration: TextDecoration.underline,
                          //decorationThickness: 2
                        ),
                      ),
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
                            "assets/${widget.netimage}",
                            height: 140,
                            width: 200,
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
                                      StateSetter setDelState) {
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
                                                      "assets/${widget.netimage}"),
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
                                            child: Text(widget.mytitle=="AFA"?"AFA MINUTES OFFERS":"$widget.mytitle DATA OFFER",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color:widget.mytitle == "AFA"?
                                                  const Color.fromARGB(255, 77, 14, 9)
                                                  : widget.mytitle == "MTN"
                                                      ? const Color.fromARGB(
                                                          255, 99, 89, 3)
                                                      : widget.mytitle == "TELECEL"
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
          widget.mytitle=="AIRTELTIGO"?Card(
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
                            setState(() {
                              selbtn = "ishare";
                              _pricelist=[];
                              for (int a = 0;
                                            a < widget.pricelist.length;
                                            a++) {
                                          if (widget.pricelist[a]["network_key"] ==
                                              "ishare" && widget.pricelist[a]["price"] !=null ){
                                           // setState(() {
                                         
                                                _pricelist.add({
            'capacity': int.tryParse(widget.pricelist[a]["capacity"]),
            'price': widget.pricelist[a]["price"],
            'buy_price': widget.pricelist[a]["buy_price"],
            'profit': widget.pricelist[a]["profit"],
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
                            setState(() {
                              selbtn = "bigtime";
                              _pricelist=[];
                              for (int a = 0;
                                            a < widget.pricelist.length;
                                            a++) {
                                          if (widget.pricelist[a]["network_key"] ==
                                              "bigtime" && widget.pricelist[a]["price"] !=null ){
                                           // setState(() {
                                          _pricelist.add({
            'capacity': widget.pricelist[a]["capacity"],
            'price': widget.pricelist[a]["price"],
            'buy_price': widget.pricelist[a]["buy_price"],
            'profit': widget.pricelist[a]["profit"],
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
                                    widget.mytitle=="AFA"?
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
                                                        setState(() {
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
                                                            print(title2);
                                                       // Navigator.of(context)
                                                         //   .pop();
                                                       
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
                                                        setState(() {
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
                                                        print(title2);
                                                        Navigator.of(context)
                                                            .pop();
                                                        //Navigator.of(context)
                                                         //   .pop();
                                                      
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
                              color: widget.mytitle=="AFA"?
                              const Color.fromARGB(255, 233, 140, 10)
                              :widget.mytitle=="MTN"? const Color.fromARGB(255, 243, 253, 104): const Color.fromARGB(255, 253, 104, 104),
                              elevation: 5,
                              child: SizedBox(
                                height: 30,
                                width: 80,
                                child: Center(
                                    child: Text("  Select  > ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: widget.mytitle=="MTN"? Colors.black : Colors.white,
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
        setState(() {
          rphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(rphoneController.text.length>10){
              setState(() {
                
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
                      widget.mytitle=="MTN"? const Text.rich(
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
                      widget.mytitle=="AFA"? const Text.rich(
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
        setState(() {
          alertphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(alertphoneController.text.length>10){
              setState(() {
                
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
                              setState(() {
                                FocusScope.of(context).requestFocus(_focusReceive);
                              });
                              
                            }else if(alertphoneController.text.trim().isEmpty){
                              setState(() {
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
                            network: widget.mytitle=="AFA"?"afa-talktime":widget.mytitle=="MTN"?'mtn':widget.mytitle=="TELECEL"?'telecel':selbtn,
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
                                netimage: widget.netimage,
                                mytitle: widget.mytitle,
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
                            network: widget.mytitle=="AFA"?"afa-talktime":widget.mytitle=="MTN"?'mtn':widget.mytitle=="TELECEL"?'telecel':selbtn,
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
                                netimage: widget.netimage,
                                mytitle: widget.mytitle,
                          ),
                        ),
                             );
                               }
                             result=="No Payment"?
                             null
                             :
                             setState(() {
                               title2 = "-- Choose Bundle --";
                            rphoneController.text = "";
                            alertphoneController.text = "";
                            //getbalance();
                            Navigator.of(context).pop();
                             });

                            });
                            
                            /* var orderid =
                                DateFormat("ayyMdhms").format(DateTime.now());
                             Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                orderlist["network"] = widget.mytitle=="MTN"?'mtn':widget.mytitle=="TELECEL"?'telecel':"";
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
                                  showSuccessDialog1({widget.netimage}, orderid);
                                  
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
                              "network": widget.mytitle=="AFA"?"afa-talktime": widget.mytitle=="MTN"?'mtn':widget.mytitle=="TELECEL"?'telecel':selbtn,
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

                                orderlist["network"] = widget.mytitle=="AFA"?"afa-talktime": widget.mytitle=="MTN"?'mtn':widget.mytitle=="TELECEL"?'telecel':selbtn;
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
                                  showSuccessDialog1({widget.netimage}, orderid,widget.mytitle);
                                  
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
                            //showSuccessDialog1({widget.netimage}, "INV123",widget.mytitle);
                            }
                          },
                          child: Card(
                              color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 253, 229, 11)
                                  : widget.mytitle == "TELECEL"
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
                                              color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
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
            ))
    );
  }

   _launchWhatsApp(String msg) async {
    const phoneNumber = '233553123698'; // WITHOUT '+'
     var whatsappUrl = Uri.parse(
                     "whatsapp://send?phone=$phoneNumber" 
                     "&text=${Uri.encodeComponent("**Hello FKDataHub!**.\nI have a complain on the Order Reference : *$msg*.\n\n")}");
     try {
       launchUrl(whatsappUrl);
     } catch (e) {
       debugPrint(e.toString());
     }}
}
