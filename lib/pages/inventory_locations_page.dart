import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_ledger_service.dart';

class InventoryLocationsPage extends StatelessWidget {
  const InventoryLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service=InventoryLedgerService();
    return Scaffold(
      appBar:AppBar(title:const Text('Inventory Locations')),
      floatingActionButton:FloatingActionButton.extended(
        onPressed:()=>_add(context,service),
        icon:const Icon(Icons.add_location_alt_outlined),
        label:const Text('Add location'),
      ),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream:service.locations(),
        builder:(context,snap){
          if(snap.hasError)return const Center(child:Text('Unable to load locations.'));
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('No inventory locations.'));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d=docs[i].data();
              return ListTile(
                leading:const Icon(Icons.store_mall_directory_outlined),
                title:Text(d['name']?.toString()??'Location'),
                subtitle:Text(d['address']?.toString()??''),
                trailing:Text(d['active']==true?'Active':'Inactive'),
              );
            },
          );
        },
      ),
    );
  }

  void _add(BuildContext context,InventoryLedgerService service){
    final name=TextEditingController(),address=TextEditingController();
    showDialog(context:context,builder:(_)=>AlertDialog(
      title:const Text('New inventory location'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'Name')),
        TextField(controller:address,decoration:const InputDecoration(labelText:'Address')),
      ]),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
        FilledButton(onPressed:()async{
          await service.saveLocation(
            id:DateTime.now().millisecondsSinceEpoch.toString(),
            name:name.text,address:address.text,active:true);
          if(context.mounted)Navigator.pop(context);
        },child:const Text('Save'))
      ],
    ));
  }
}
