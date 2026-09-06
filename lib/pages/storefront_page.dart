import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storefront_catalog_service.dart';

class StorefrontPage extends StatelessWidget {
  final String businessId;
  final String businessName;

  const StorefrontPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    final service = StorefrontCatalogService();
    return Scaffold(
      appBar: AppBar(title: Text(businessName)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.storefrontItems(businessId),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load storefront.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No products available.'));
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: .72,
            ),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final stock = (d['stock'] as num?)?.toInt() ?? 0;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(d['title']?.toString() ?? 'Product',
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${d['currency'] ?? ''} ${d['price'] ?? 0}'),
                      Text(stock > 0 ? 'In stock: $stock' : 'Out of stock'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
