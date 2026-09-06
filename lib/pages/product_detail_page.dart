import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/product_variant_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String businessId;
  final String productId;
  final String title;

  const ProductDetailPage({
    super.key,
    required this.businessId,
    required this.productId,
    required this.title,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedVariant;

  @override
  Widget build(BuildContext context) {
    final service = ProductVariantService();
    final ref = FirebaseFirestore.instance
        .collection('users').doc(widget.businessId)
        .collection('catalog').doc(widget.productId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, productSnap) {
          if (!productSnap.hasData) return const Center(child: CircularProgressIndicator());
          final p=productSnap.data!.data() ?? {};
          final images=List<String>.from(p['images'] ?? const []);
          final variantsRef=FirebaseFirestore.instance
              .collection('users').doc(widget.businessId)
              .collection('catalog').doc(widget.productId).collection('variants');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 260,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all()),
                child: images.isEmpty
                    ? const Icon(Icons.photo_library_outlined, size: 70)
                    : Image.network(images.first, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(widget.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(p['description']?.toString() ?? ''),
              const SizedBox(height: 18),
              StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                stream: variantsRef.snapshots(),
                builder: (_, snap) {
                  final docs=snap.data?.docs ?? const [];
                  if (docs.isEmpty) return Text('${p['currency'] ?? ''} ${p['price'] ?? 0}');
                  return DropdownButtonFormField<String>(
                    value: selectedVariant,
                    decoration: const InputDecoration(labelText: 'Choose variant'),
                    items: docs.map((d) {
                      final v=d.data();
                      return DropdownMenuItem(
                        value:d.id,
                        child:Text('${v['name']} • ${v['currency'] ?? p['currency'] ?? ''} ${v['price'] ?? p['price'] ?? 0}'),
                      );
                    }).toList(),
                    onChanged:(v)=>setState(()=>selectedVariant=v),
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: selectedVariant == null && false ? null : () {},
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Add to cart'),
              ),
            ],
          );
        },
      ),
    );
  }
}
