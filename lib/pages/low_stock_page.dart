import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LowStockPage extends StatelessWidget {
  const LowStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseFirestore.instance;
    return Scaffold(
      appBar:AppBar(title:const Text('Low Stock')),
      body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream: (() {
          // Caller should replace this with the authenticated merchant's catalog.
          // Kept as a UI foundation to avoid exposing arbitrary merchant data.
          return const Stream<QuerySnapshot<Map<String,dynamic>>>.empty();
        })(),
        builder:(context,snap){
          if(!snap.hasData)return const Center(child:Text('Low-stock alerts will appear here.'));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
