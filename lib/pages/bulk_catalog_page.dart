import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_management_service.dart';

class BulkCatalogPage extends StatefulWidget {
  const BulkCatalogPage({super.key});
  @override State<BulkCatalogPage> createState()=>_BulkCatalogPageState();
}

class _BulkCatalogPageState extends State<BulkCatalogPage> {
  final service=InventoryManagementService();
  final sku=TextEditingController();
  final title=TextEditingController();
  final price=TextEditingController();
  final stock=TextEditingController(text:'0');

  @override void dispose(){sku.dispose();title.dispose();price.dispose();stock.dispose();super.dispose();}

  Future<void> add() async {
    if(service.uid.isEmpty || title.text.trim().isEmpty) return;
    final ref=service.catalog.doc();
    await ref.set({
      'title':title.text.trim(),
      'sku':sku.text.trim().toUpperCase(),
      'price':int.tryParse(price.text)??0,
      'stock':int.tryParse(stock.text)??0,
      'lowStockThreshold':5,
      'lowStock':(int.tryParse(stock.text)??0)<=5,
      'active':true,
      'images':[],
      'variants':[],
      'createdAt':FieldValue.serverTimestamp(),
      'updatedAt':FieldValue.serverTimestamp(),
    });
    title.clear(); sku.clear(); price.clear(); stock.text='0';
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Bulk Catalog')),
    body:ListView(
      padding:const EdgeInsets.all(16),
      children:[
        const Text('Quick product entry',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
        const SizedBox(height:14),
        TextField(controller:title,decoration:const InputDecoration(labelText:'Product name')),
        TextField(controller:sku,decoration:const InputDecoration(labelText:'SKU')),
        TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Price')),
        TextField(controller:stock,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Opening stock')),
        const SizedBox(height:20),
        FilledButton.icon(onPressed:add,icon:const Icon(Icons.add_box_outlined),label:const Text('Add product')),
        const SizedBox(height:24),
        const Text('CSV import/export can be connected to this model when file handling is added.'),
      ],
    ),
  );
}
