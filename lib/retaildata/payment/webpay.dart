import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // only for Flutter Web
import 'dart:js_util' as js_util;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class PaystackOnePageApp extends StatefulWidget {
  final double amount, profit, buy_price;
  final String email, netimage;
  final int capacity;
  final String reference, network,receiver,alert_sms,date,time,mytitle;


  const PaystackOnePageApp({
    super.key,
    required this.amount,
    required this.email,
    required this.reference,
    required this.alert_sms,
    required this.netimage,
    required this.capacity,
    required this.date,
    required this.network,
    required this.receiver,
    required this.time,
    required this.profit,
    required this.buy_price,
    required this.mytitle,
  });

  @override
  State<PaystackOnePageApp> createState() => _PaystackPaymentPageState();
}


class _PaystackPaymentPageState extends State<PaystackOnePageApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay with Paystack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: PayPage(
        amount: widget.amount,
        profit: widget.profit,
        buy_price: widget.buy_price,
        email: widget.email,
        netimage: widget.netimage,
        capacity: widget.capacity,
        reference: widget.reference,
        network: widget.network,
        receiver: widget.receiver,
        alert_sms: widget.alert_sms,
        date: widget.date,
        time: widget.time,
        mytitle: widget.mytitle,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PayPage extends StatefulWidget {
  final double amount, profit, buy_price;
  final String email, netimage;
  final int capacity;
  final String reference, network,receiver,alert_sms,date,time,mytitle;


  const PayPage({
    super.key,
    required this.amount,
    required this.email,
    required this.reference,
    required this.alert_sms,
    required this.netimage,
    required this.capacity,
    required this.date,
    required this.network,
    required this.receiver,
    required this.time,
    required this.profit,
    required this.buy_price,
    required this.mytitle,
  });


  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final _email = TextEditingController();
  final _amount = TextEditingController(); // in major currency units (e.g., NGN)
  String _status = 'Idle';
  StreamSubscription<html.MessageEvent>? _sub;

  // TODO: replace with your real Paystack public key (never use secret key on client!)
  static const String paystackPublicKey = 'pk_live_56b9072d3c335843d4aba985843cd4704d4dbf86';
    //static const String paystackPublicKey = 'pk_test_026ea4ed024876de980a1a7244ca49a748fd825c';
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
    super.initState();
    _sub = html.window.onMessage.listen((event) async {
      try {
        final data = jsonDecode(event.data as String);
        if (data['event'] == 'PAYSTACK_SUCCESS') {
          setState(() => _status = 'Success! Ref: ${data['reference']}');
          showDialogProcessing();
           //check balance
      try {
      // var request = http.Request('GET', Uri.parse('http://127.0.0.1:8000/api/v1/walletBalance'));
      //Map<String, dynamic> getbal = [];
      const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
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
        var rawbalnce = getbal['data']["walletBalance"];
        double finalbalance = double.tryParse(rawbalnce) ?? 0.0;
        if (kDebugMode) {
          print("Response Balance: $finalbalance");
        }
        if(widget.amount>finalbalance){
          Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                orderlist["network"] = widget.network;
                                orderlist["receiver"] = widget.receiver;
                                orderlist["reference"] = widget.reference;
                                orderlist["amount"] = widget.capacity;
                                orderlist["price"] = widget.amount;
                                orderlist["alert_sms"] = widget.alert_sms;
                                orderlist["buy_price"] = widget.buy_price;
                                orderlist["profit"] = widget.profit;
                                orderlist["status"] = "pending";
                                orderlist["walletstatus"] = "unavailable";
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
                                    .doc(widget.reference)
                                    .set(orderlist)
                                    .whenComplete(() {
                                      //success = true;

                                     // if (mounted) {
                                        Navigator.of(context).pop(); // Close processing dialog
                                        showSuccessDialog1(widget.netimage, widget.reference, widget.mytitle);
                                     // }
                                    });
        }
          
      else {
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
                              "network": widget.network,
                              "reference": widget.reference,
                              "receiver": widget.receiver,
                              "amount": widget.capacity
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

                                orderlist["network"] = widget.network;
                                orderlist["receiver"] = widget.receiver;
                                orderlist["reference"] = widget.reference;
                                orderlist["amount"] = widget.capacity;
                                orderlist["price"] = widget.amount;
                                orderlist["alert_sms"] =widget.alert_sms;
                                orderlist["buy_price"] = widget.buy_price;
                                orderlist["profit"] = widget.profit;
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
                                    .doc(widget.reference)
                                    .set(orderlist)
                                    .whenComplete(() {
                                  Navigator.of(context).pop();
                                  //getbalance();
                                  showSuccessDialog1(widget.netimage, widget.reference,widget.mytitle);
                                  
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
                            }
      }
      }else{
        //
        Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                orderlist["network"] = widget.network;
                                orderlist["receiver"] = widget.receiver;
                                orderlist["reference"] = widget.reference;
                                orderlist["amount"] = widget.capacity;
                                orderlist["price"] = widget.amount;
                                orderlist["alert_sms"] = widget.alert_sms;
                                orderlist["buy_price"] = widget.buy_price;
                                orderlist["profit"] = widget.profit;
                                orderlist["status"] = "pending";
                                orderlist["walletstatus"] = "unavailable";
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
                                    .doc(widget.reference)
                                    .set(orderlist)
                                    .whenComplete(() {
                                      //success = true;

                                     // if (mounted) {
                                        Navigator.of(context).pop(); // Close processing dialog
                                        showSuccessDialog1(widget.netimage, widget.reference, widget.mytitle);
                                     // }
                                    });
      }
      } catch (e) {
      print("Error: $e");
    }
          // In production: send `reference` to your backend to VERIFY the transaction server-side.
        } else if (data['event'] == 'PAYSTACK_CLOSED') {
          setState(() => _status = 'Checkout closed.');
        } else if (data['event'] == 'PAYSTACK_ERROR') {
          setState(() => _status = 'Error: ${data['message']}');
        }
      } catch (_) {
        // Not our message; ignore.
      }
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
                //height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 253, 229, 11)
                                  : widget.mytitle == "TELECEL"
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
                        color:   widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? Colors.black : Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Placed Successfully.",
                    style: TextStyle(
                        fontSize: 20,
                        color:   widget.mytitle == "MTN" || widget.mytitle=="AFA"
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
                        text: widget.reference,
                        style: TextStyle(
                          fontSize: 20,
                          color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : widget.mytitle == "TELECEL"
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
                        text: widget.receiver,
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
                        text:  widget.mytitle=="AFA"?"${widget.capacity} mins":"${widget.capacity} GIG",
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
                        text: "GH₵ ${widget.amount}",
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
                  
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
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

  @override
  void dispose() {
    _sub?.cancel();
    _email.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _startPayment() {
   
    // Paystack expects the smallest unit (kobo for NGN): multiply by 100
    final int amountInKobo = (widget.amount * 100).round();

    final reference =
        'FLWEB_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecondsSinceEpoch % 8999))}';

    final options = {
      'key': paystackPublicKey,
      'email': widget.email,
      'amount': amountInKobo,
      'currency': 'GHS', // change to GHS/USD etc. if your account supports it
      'reference': widget.reference,
    };

    setState(() => _status = 'Opening checkout…');

    // Call the JS helper defined in index.html
    js_util.callMethod(html.window, 'payWithPaystack', [js_util.jsify(options)]);
  }

@override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Transaction Summary',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow('Network Type', widget.network),
                  _buildRow('Receiver Number', widget.receiver),
                  _buildRow('Capacity', widget.capacity.toString()),
                  _buildRow('Cost (GHS)', widget.amount.toString()),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _startPayment,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Pay',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 119, 117, 117))),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

}
