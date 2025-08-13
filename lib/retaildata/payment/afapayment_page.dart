import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;


class AFAPaystackPaymentPage extends StatefulWidget {
  final double amount;
  final String email;
  final String reference, receiver,alert_sms,date,time;


  const AFAPaystackPaymentPage({
    super.key,
    required this.amount,
    required this.email,
    required this.reference,
    required this.alert_sms,
    required this.date,
    required this.receiver,
    required this.time
  });

  @override
  State<AFAPaystackPaymentPage> createState() => _PaystackPaymentPageState();
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

class _PaystackPaymentPageState extends State<AFAPaystackPaymentPage> {
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
          throw PaymentException(data['message']);
        } else {
          throw PaymentException('Payment initialization failed with status: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        throw PaymentException('Network error: Please check your internet connection');
      }
      await Future.delayed(initialDelay * attempt);
    } on TimeoutException catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        throw PaymentException('Request timed out: Please try again');
      }
      await Future.delayed(initialDelay * attempt);
    } on PaymentException catch (e) {
      // Re-throw immediately if it's a payment-specific error
      throw e;
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        throw PaymentException('Payment processing error: ${e.toString()}');
      }
      await Future.delayed(initialDelay * attempt);
    }
  }
  
  throw PaymentException('Failed to initialize payment after $maxRetries attempts');
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
          throw PaymentVerificationException('Payment failed or was declined');
        } else if (status == 'abandoned') {
          throw PaymentVerificationException('Payment was abandoned');
        }
        // If not final status, will retry
      } else {
        throw PaymentVerificationException(
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
  
  throw PaymentVerificationException('Could not verify payment after $maxRetries attempts');
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
      
      // 1. Place order with API
      const String authToken = "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
      const String apiUrl = 'https://test.gdsonline.app/api/v1/minutesOrder';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "reference": widget.reference,
          "minutes": widget.amount,
          "receiver": widget.receiver
         
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);
      debugPrint('Order placed successfully: $responseData');

      // 2. Save to Firestore
      final orderData = {
        //"network": widget.network,
        "receiver": widget.receiver,
        "reference": widget.reference,
        //"amount": widget.capacity,
        "price": widget.amount,
        "alert_sms": widget.alert_sms,
        "date": widget.date,
        "time": widget.time,
        "status": "completed",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('afaregistration')
          .doc(widget.reference)
          .set(orderData);

      success = true;
      
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog
        showSuccessDialog1("", widget.reference);
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
    throw Exception('Failed to complete order after $maxRetries attempts');
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


  showSuccessDialog1(String netimage, orderid) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                children: [
                  const Center(
                      child: Text(
                    "MTN Order Placed Successfully.",
                    style: TextStyle(
                        fontSize: 22,
                        color: Color.fromARGB(255, 58, 54, 1),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
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
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 131, 118, 2),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 131, 118, 2),
                        ))
                  ])),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text.rich(TextSpan(children: [
                     TextSpan(
                        text: "Capacity : ",
                        style: TextStyle(
                          fontSize: 18,
                          //fontWeight: FontWeight.bold,
                        )),
                     TextSpan(
                        text: "GIG",
                        style:  TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 131, 118, 2),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 131, 118, 2),
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