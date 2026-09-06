import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_ledger_service.dart';

class InventoryLedgerPage extends StatelessWidget {
  final String productId;
  const InventoryLedgerPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final service=InventoryLedgerService();
    return Scaffold(
      appBar:AppBar(title:const Text('Inventory Ledger')),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream:service.movements(productId),
        builder:(context,snap){
          if(snap.hasError)return const Center(child:Text('Unable to load inventory history.'));
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('No stock movements yet.'));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d=docs[i].data();
              return ListTile(
                leading:const Icon(Icons.swap_vert),
                title:Text('${d['type']??'movement'} • ${d['quantity']??0}'),
                subtitle:Text('Location: ${d['locationId']??'—'}\n${d['note']??''}'),
              );
            },
          );
        },
      ),
    );
  }
}
