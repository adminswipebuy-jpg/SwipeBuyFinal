import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storefront_catalog_service.dart';

class CatalogManagementPage extends StatelessWidget {
  const CatalogManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = StorefrontCatalogService();
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog & Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, service),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.myItems(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load catalog.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs=snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Your catalog is empty.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d=docs[i].data();
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(d['title']?.toString() ?? 'Product'),
                subtitle: Text('${d['currency'] ?? ''} ${d['price'] ?? 0} • Stock ${d['stock'] ?? 0}'),
                trailing: Switch(
                  value: d['active'] == true,
                  onChanged: (_) => service.deleteItem(docs[i].id),
                ),
                onTap: () => _showEditor(context, service, docs[i].id, d),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditor(BuildContext context, StorefrontCatalogService service,
      [String? id, Map<String,dynamic>? existing]) {
    final title=TextEditingController(text: existing?['title']?.toString() ?? '');
    final desc=TextEditingController(text: existing?['description']?.toString() ?? '');
    final price=TextEditingController(text: existing?['price']?.toString() ?? '');
    final stock=TextEditingController(text: existing?['stock']?.toString() ?? '0');
    final currency=TextEditingController(text: existing?['currency']?.toString() ?? 'GHS');
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(id == null ? 'Add product' : 'Edit product'),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller:title, decoration:const InputDecoration(labelText:'Product name')),
        TextField(controller:desc, decoration:const InputDecoration(labelText:'Description')),
        TextField(controller:price, keyboardType:TextInputType.number, decoration:const InputDecoration(labelText:'Price')),
        TextField(controller:currency, decoration:const InputDecoration(labelText:'Currency')),
        TextField(controller:stock, keyboardType:TextInputType.number, decoration:const InputDecoration(labelText:'Stock')),
      ])),
      actions: [
        TextButton(onPressed:()=>Navigator.pop(context), child:const Text('Cancel')),
        FilledButton(onPressed:() async {
          final item=CatalogItem(
            id:id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title:title.text.trim(), description:desc.text.trim(),
            price:int.tryParse(price.text) ?? 0,
            currency:currency.text.trim().toUpperCase(),
            stock:int.tryParse(stock.text) ?? 0,
            images:List<String>.from(existing?['images'] ?? const []),
            variants:List<String>.from(existing?['variants'] ?? const []),
            active:true,
          );
          await service.saveItem(item);
          if (context.mounted) Navigator.pop(context);
        }, child:const Text('Save')),
      ],
    ));
  }
}
