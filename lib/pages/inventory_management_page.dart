import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_management_service.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});
  @override State<InventoryManagementPage> createState()=>_InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> {
  final service=InventoryManagementService();
  final selected=<String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions:[
          if(selected.isNotEmpty) PopupMenuButton<String>(
            onSelected:(v)=>service.bulkSetActive(selected.toList(),v=='active'),
            itemBuilder:(_)=>const[
              PopupMenuItem(value:'active',child:Text('Activate selected')),
              PopupMenuItem(value:'inactive',child:Text('Deactivate selected')),
            ],
          ),
        ],
      ),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream:service.catalog.orderBy('updatedAt',descending:true).snapshots(),
        builder:(context,snap){
          if(snap.hasError)return const Center(child:Text('Unable to load inventory.'));
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('No inventory items.'));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d=docs[i].data();
              final stock=(d['stock'] as num?)?.toInt()??0;
              final threshold=(d['lowStockThreshold'] as num?)?.toInt()??5;
              final low=stock<=threshold;
              return CheckboxListTile(
                value:selected.contains(docs[i].id),
                onChanged:(v)=>setState(()=>v==true
                    ? selected.add(docs[i].id)
                    : selected.remove(docs[i].id)),
                title:Text(d['title']?.toString()??'Product'),
                subtitle:Text(
                  'SKU: ${d['sku']?.toString().isNotEmpty==true?d['sku']:'—'}\n'
                  'Stock: $stock • Alert at: $threshold${low?' • LOW STOCK':''}',
                ),
                secondary:Icon(low?Icons.warning_amber_outlined:Icons.inventory_2_outlined),
              );
            },
          );
        },
      ),
    );
  }
}
