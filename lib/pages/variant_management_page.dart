import 'package:flutter/material.dart';
import '../services/product_variant_service.dart';

class VariantManagementPage extends StatelessWidget {
  final String productId;
  const VariantManagementPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final service=ProductVariantService();
    return Scaffold(
      appBar: AppBar(title: const Text('Variants & SKUs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:()=>_add(context,service),
        icon:const Icon(Icons.add),
        label:const Text('Add variant'),
      ),
      body:StreamBuilder(
        stream:service.variants(productId),
        builder:(context,snap){
          if(!snap.hasData)return const Center(child:CircularProgressIndicator());
          final docs=snap.data!.docs;
          if(docs.isEmpty)return const Center(child:Text('No variants yet.'));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d=docs[i].data();
              return ListTile(
                title:Text(d['name']?.toString()??'Variant'),
                subtitle:Text('SKU ${d['sku']??''} • Stock ${d['stock']??0} • Price ${d['price']??0}'),
                trailing:Icon(d['active']==true?Icons.check_circle:Icons.pause_circle),
              );
            },
          );
        },
      ),
    );
  }

  void _add(BuildContext context,ProductVariantService service){
    final name=TextEditingController(),sku=TextEditingController(),
        price=TextEditingController(text:'0'),stock=TextEditingController(text:'0');
    showDialog(context:context,builder:(_)=>AlertDialog(
      title:const Text('New variant'),
      content:SingleChildScrollView(child:Column(children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'Variant name')),
        TextField(controller:sku,decoration:const InputDecoration(labelText:'SKU')),
        TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Price')),
        TextField(controller:stock,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Stock')),
      ])),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
        FilledButton(onPressed:()async{
          await service.saveVariant(productId,ProductVariant(
            id:DateTime.now().millisecondsSinceEpoch.toString(),
            name:name.text.trim(),sku:sku.text,price:int.tryParse(price.text)??0,
            stock:int.tryParse(stock.text)??0,active:true));
          if(context.mounted)Navigator.pop(context);
        },child:const Text('Save'))
      ],
    ));
  }
}
