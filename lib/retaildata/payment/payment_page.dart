import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;


class PaystackPaymentPage extends StatefulWidget {
  final double amount, profit, buy_price;
  final String email, netimage;
  final int capacity;
  final String reference, network,receiver,alert_sms,date,time,mytitle;


  const PaystackPaymentPage({
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
  State<PaystackPaymentPage> createState() => _PaystackPaymentPageState();
}

// Custom exception class for payment errors
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  
  @override
  String toString() => message;
}

class PaymentVerificationException implements Exception {
  final String message;
  PaymentVerificationException(this.message);
  
  @override
  String toString() => message;
}

class _PaystackPaymentPageState extends State<PaystackPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  bool _isVerifying = false;

  static const String _secretKey = 'sk_live_59d6bddaaa94d236357b5ad260de55c38d28c0a5';

  Future<String> _initializePayment() async {
  const int maxRetries = 3;
  const Duration initialDelay = Duration(seconds: 1);
  int attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (widget.amount * 100).toStringAsFixed(0),
          'email': widget.email,
          'reference': widget.reference,
          'currency': 'GHS',
          'callback_url': 'https://your-callback-url.com',
          'metadata': {
            'custom_fields': [
              {
                'display_name': 'Payment For',
                'variable_name': 'payment_for',
                'value': 'Mobile Data Bundle'
              }
            ]
          }
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == true) {
        return data['data']['authorization_url'];
      } else {
        // Check for specific error conditions
        if (data['message'] != null) {
          showErrorDialog(data['message']);
        } else {
          showErrorDialog('Payment initialization failed with status: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        showErrorDialog('Network error: Please check your internet connection');
      }
      await Future.delayed(initialDelay * attempt);
    } on TimeoutException catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        showErrorDialog('Request timed out: Please try again');
      }
      await Future.delayed(initialDelay * attempt);
    } on PaymentException catch (e) {
      // Re-throw immediately if it's a payment-specific error
      showErrorDialog(e.toString());
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        showErrorDialog('Payment processing error: ${e.toString()}');
      }
      await Future.delayed(initialDelay * attempt);
    }
  }
  
  throw showErrorDialog('Failed to initialize payment after $maxRetries attempts');
}



  Future<bool> _verifyPayment() async {
  const int maxRetries = 5; // More retries for verification
  const Duration initialDelay = Duration(seconds: 2); // Longer initial delay
  int attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/${widget.reference}'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      
      // Comprehensive status checking
      if (response.statusCode == 200 && data['status'] == true) {
        final status = data['data']['status'];
        final amountMatches = data['data']['amount'] == (widget.amount * 100).round();
        
        if (status == 'success' && amountMatches) {
          return true;
        } else if (status == 'failed') {
          throw showErrorDialog('Payment failed or was declined');
        } else if (status == 'abandoned') {
          throw showErrorDialog('Payment was abandoned');
        }
        // If not final status, will retry
      } else {
        throw showErrorDialog(
          data['message'] ?? 'Verification failed with status ${response.statusCode}'
        );
      }
    } on SocketException {
      debugPrint('Network error during verification attempt ${attempt + 1}');
    } on TimeoutException {
      debugPrint('Verification timeout attempt ${attempt + 1}');
    } on PaymentVerificationException catch (e) {
      debugPrint('Payment verification failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected verification error: $e');
    }
    
    attempt++;
    if (attempt < maxRetries) {
      // Exponential backoff with jitter
      final delay = initialDelay * (attempt + 1) + Duration(milliseconds: Random().nextInt(1000));
      await Future.delayed(delay);
      debugPrint('Retrying verification (attempt ${attempt + 1})...');
    }
  }
  
  throw showErrorDialog('Could not verify payment after $maxRetries attempts');
}

  Future<void> _handlePaymentSuccess() async {
  if (_paymentCompleted || _isVerifying) return;

  setState(() => _isVerifying = true);

  try {
    final isVerified = await _verifyPayment();
    
    if (!isVerified || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed')),
      );
      return;
    }

    setState(() => _paymentCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful!')),
    );
    
    await showDialogProcessing();
    
    // Place order and save to Firestore
    await _placeOrderAndSaveToFirestore();
    
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    debugPrint('Payment handling error: $e');
  } finally {
    if (mounted) {
      setState(() => _isVerifying = false);
    }
  }
}

Future<void> _placeOrderAndSaveToFirestore() async {
  const int maxRetries = 3;
  int attempt = 0;
  bool success = false;
  
  while (attempt < maxRetries && !success && mounted) {
    try {
      attempt++;

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
                                      success = true;

                                      if (mounted) {
                                        Navigator.of(context).pop(); // Close processing dialog
                                        showSuccessDialog1(widget.netimage, widget.reference, widget.mytitle);
                                      }
                                    });
        }
          
      } else {
                   
      // 1. Place order with API
      const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
      const String apiUrl = 'https://test.gdsonline.app/api/v1/placeOrder';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "network": widget.network,
          "reference": widget.reference,
          "receiver": widget.receiver,
          "amount": widget.capacity
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}');
      }
      else{
      final responseData = jsonDecode(response.body);
      debugPrint('Order placed successfully: $responseData');

      // 2. Save to Firestore
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
                                      success = true;

                                      if (mounted) {
                                        Navigator.of(context).pop(); // Close processing dialog
                                        showSuccessDialog1(widget.netimage, widget.reference, widget.mytitle);
                                      }
                                    });
      }
      }
    } catch (e) {
      print("Error: $e");
    }
      
    } on SocketException catch (e) {
      debugPrint('Network error during attempt $attempt: $e');
      if (attempt >= maxRetries) throw e;
      await Future.delayed(Duration(seconds: attempt * 2));
    } on TimeoutException catch (e) {
      debugPrint('Timeout during attempt $attempt: $e');
      if (attempt >= maxRetries) throw e;
      await Future.delayed(Duration(seconds: attempt * 2));
    } catch (e) {
      debugPrint('Error in attempt $attempt: $e');
      if (attempt >= maxRetries) throw e;
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }

  if (!success && mounted) {
   showErrorDialog('Failed to complete order after $maxRetries attempts');
  }
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
            content: Column(
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
            ),
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


  showSuccessDialog1(String netimage, orderid, mytitle) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                children: [
                  Card(
                  ///  color: widget.mytitle == "MTN"
                      //            ? const Color.fromARGB(255, 253, 229, 11)
                             //     : widget.mytitle == "TELECEL"
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
                     Text(widget.mytitle=="AFA"?"AFA MINUTES":
                    "$widget.mytitle Order",
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
                          color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : widget.mytitle == "TELECEL"
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
                          color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : widget.mytitle == "TELECEL"
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
                          color: widget.mytitle == "MTN" || widget.mytitle=="AFA"
                                  ? const Color.fromARGB(255, 82, 52, 3)
                                  : widget.mytitle == "TELECEL"
                                      ? const Color.fromARGB(255, 111, 6, 6)
                                      : const Color.fromARGB(255, 20, 3, 82),
                        ))
                  ]))
                ],
              );
            }),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  /*setState(() {
                    title2 = "-- Choose Bundle --";
                    rphoneController.text = "";
                    alertphoneController.text = "";
                    //}
                  });*/
                  Navigator.pop(context);
                  Navigator.pop(context, "Paid");
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => setState(() => _isLoading = progress < 100),
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            if (url.contains('success') || url.contains('callback')) {
              _handlePaymentSuccess();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('success') || request.url.contains('callback')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    
    _initializePayment().then((url) {
      _controller.loadRequest(Uri.parse(url));
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_paymentCompleted) {
          final shouldClose = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Payment?'),
              content: const Text('Are you sure you want to cancel this payment?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return shouldClose ?? false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: !kIsWeb,
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!_paymentCompleted && mounted) {
                Navigator.pop(context, 'No Payment');
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading || _isVerifying)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}