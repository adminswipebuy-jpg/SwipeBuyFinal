import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_workflow_service.dart';

class InventoryWorkflowsPage extends StatelessWidget {
  const InventoryWorkflowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service=InventoryWorkflowService();
    return Scaffold(
      appBar:AppBar(title:const Text('Inventory Workflows')),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream:service.transfers(),
        builder:(context,snap){
          if(snap.hasError)return const Center(child:Text('Unable to load transfers.'));
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('No inventory transfers.'));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d=docs[i].data();
              return Card(
                child:ListTile(
                  leading:const Icon(Icons.compare_arrows_outlined),
                  title:Text('${d['quantity']??0} units • ${d['status']??'requested'}'),
                  subtitle:Text('${d['fromLocationId']??'—'} → ${d['toLocationId']??'—'}\nProduct: ${d['productId']??'—'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
