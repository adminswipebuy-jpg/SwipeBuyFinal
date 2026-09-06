import 'package:cloud_functions/cloud_functions.dart';

class CheckoutSession {
  final String sessionId;
  final String orderId;
  final String provider;
  final String status;
  final String? checkoutUrl;

  CheckoutSession({
    required this.sessionId,
    required this.orderId,
    required this.provider,
    required this.status,
    this.checkoutUrl,
  });

  factory CheckoutSession.fromMap(Map<dynamic, dynamic> map) {
    return CheckoutSession(
      sessionId: (map['sessionId'] ?? '') as String,
      orderId: (map['orderId'] ?? '') as String,
      provider: (map['provider'] ?? '') as String,
      status: (map['status'] ?? 'pending') as String,
      checkoutUrl: map['checkoutUrl'] as String?,
    );
  }
}

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<CheckoutSession> createCheckout({
    required String orderId,
    required String provider,
    required String idempotencyKey,
  }) async {
    final callable = _functions.httpsCallable('createCheckout');
    final result = await callable.call({
      'orderId': orderId,
      'provider': provider,
      'idempotencyKey': idempotencyKey,
    });
    return CheckoutSession.fromMap(result.data as Map<dynamic, dynamic>);
  }

  Future<Map<dynamic, dynamic>> verifyPayment({
    required String sessionId,
  }) async {
    final callable = _functions.httpsCallable('verifyPayment');
    final result = await callable.call({'sessionId': sessionId});
    return result.data as Map<dynamic, dynamic>;
  }
}
