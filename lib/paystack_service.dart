import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';

class PaystackService {
  // Replace with your actual Paystack public key
  static const String publicKey = '';
  
  static Future<Map<String, dynamic>> makePayment({
    required double amount,
    required String email,
    required String name,
  }) async {
    try {
      final completer = Completer<Map<String, dynamic>>();
      final reference = _generateReference();
      
      // Convert amount to pesewas (multiply by 100)
      final amountInPesewas = (amount * 100).toInt();
      
      // Create success callback
      final onSuccess = js.allowInterop((response) {
        completer.complete({
          'success': true,
          'message': 'Payment successful!',
          'reference': response['reference'],
          'transaction': response['trans'],
        });
      });
      
      // Create close callback
      final onClose = js.allowInterop(() {
        if (!completer.isCompleted) {
          completer.complete({
            'success': false,
            'message': 'Payment was cancelled',
          });
        }
      });
      
      // Set up Paystack payment
      js.context.callMethod('eval', ['''
        var handler = PaystackPop.setup({
          key: '',
          email: '$email',
          amount: $amountInPesewas,
          currency: 'GHS',
          ref: '$reference',
          metadata: {
            custom_fields: [
              {
                display_name: "Customer Name",
                variable_name: "customer_name",
                value: "$name"
              }
            ]
          },
          callback: function(response) {
            window.paystackCallback(response);
          },
          onClose: function() {
            window.paystackClose();
          }
        });
        handler.openIframe();
      ''']);
      
      // Register callbacks
      js.context['paystackCallback'] = onSuccess;
      js.context['paystackClose'] = onClose;
      
      return await completer.future;
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment initialization failed: ${e.toString()}',
      };
    }
  }
  
  static String _generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'PAY_$timestamp';
  }
}
