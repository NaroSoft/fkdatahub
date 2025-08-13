import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // only for Flutter Web
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';



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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PayPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PayPage extends StatefulWidget {
  const PayPage({super.key});

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

   @override
  void initState() {
    super.initState();
    _sub = html.window.onMessage.listen((event) {
      try {
        final data = jsonDecode(event.data as String);
        if (data['event'] == 'PAYSTACK_SUCCESS') {
          setState(() => _status = 'Success! Ref: ${data['reference']}');
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

  @override
  void dispose() {
    _sub?.cancel();
    _email.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _startPayment() {
    final email = _email.text.trim();
    final amountText = _amount.text.trim();

    if (email.isEmpty || amountText.isEmpty) {
      setState(() => _status = 'Please enter email and amount.');
      return;
    }

    final parsed = double.tryParse(amountText);
    if (parsed == null || parsed <= 0) {
      setState(() => _status = 'Enter a valid positive amount.');
      return;
    }

    // Paystack expects the smallest unit (kobo for NGN): multiply by 100
    final int amountInKobo = (parsed * 100).round();

    final reference =
        'FLWEB_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecondsSinceEpoch % 8999))}';

    final options = {
      'key': paystackPublicKey,
      'email': email,
      'amount': amountInKobo,
      'currency': 'NGN', // change to GHS/USD etc. if your account supports it
      'reference': reference,
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
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pay with Paystack',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (NGN)',
                      hintText: 'e.g. 1000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startPayment,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Pay Now'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}