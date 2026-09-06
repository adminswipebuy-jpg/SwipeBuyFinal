import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String listingId;
  final String title;
  final int quantity;
  final int unitAmount;
  final String currency;

  const CartItem({
    required this.listingId,
    required this.title,
    required this.quantity,
    required this.unitAmount,
    required this.currency,
  });

  int get subtotal => quantity * unitAmount;

  Map<String, dynamic> toMap() => {
    'listingId': listingId,
    'title': title,
    'quantity': quantity,
    'unitAmount': unitAmount,
    'currency': currency,
    'subtotal': subtotal,
  };
}

class CheckoutCartService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<void> createOrderFromCart({
    required List<CartItem> items,
    required String currency,
    required String deliveryAddress,
    required String deliveryMethod,
  }) async {
    if (uid.isEmpty || items.isEmpty) return;

    final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);

    await _db.collection('orders').add({
      'customerId': uid,
      'items': items.map((e) => e.toMap()).toList(),
      'currency': currency,
      'subtotal': subtotal,
      'deliveryAddress': deliveryAddress.trim(),
      'deliveryMethod': deliveryMethod,
      'status': 'pending',
      'paymentStatus': 'unpaid',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
