import 'package:flutter/material.dart';
import '../services/professional_network_service.dart';

class ProfessionalNetworkPage extends StatefulWidget {
  const ProfessionalNetworkPage({super.key});
  @override State<ProfessionalNetworkPage> createState() => _ProfessionalNetworkPageState();
}
class _ProfessionalNetworkPageState extends State<ProfessionalNetworkPage> {
  final search = TextEditingController();
  String filter = 'All';
  String status = 'Discover people, communities and opportunities.';
  @override void dispose(){search.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    var items = ProfessionalNetworkService.instance.discover(search.text);
    if(filter!='All') items = items.where((x)=>x.type==filter).toList();
    return Scaffold(appBar: AppBar(title: const Text('Professional Network 2.0')),
      body: ListView(padding: const EdgeInsets.all(16), children:[
        const Text('Connect. Collaborate. Grow.',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),const Text('Build professional communities and discover opportunities across SwipeBuy.',style:TextStyle(color:Colors.white60)),
        const SizedBox(height:14),TextField(controller:search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search people, communities or opportunities',border:OutlineInputBorder())),
        const SizedBox(height:10),Wrap(spacing:8,children:['All','Community','Networking','Opportunity'].map((x)=>ChoiceChip(label:Text(x),selected:filter==x,onSelected:(_)=>setState(()=>filter=x))).toList()),
        const SizedBox(height:14), ...items.map(_card),
        const SizedBox(height:10),Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(status))),
        const SizedBox(height:12),const Text('Safety: public profiles, member lists, introductions and opportunity access should be governed by privacy, moderation and backend authorization.',style:TextStyle(color:Colors.white54,fontSize:12)),
      ]));
  }
  Widget _card(Opportunity o)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Text(o.title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))),Chip(label:Text(o.type))]),
    Text('${o.organization} • ${o.location}',style:const TextStyle(color:Colors.white60)),const SizedBox(height:6),Text(o.summary),
    const SizedBox(height:8),Text('${o.members} members / participants',style:const TextStyle(color:Colors.white60)),const SizedBox(height:10),
    SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:(){ProfessionalNetworkService.instance.requestJoin(o);setState(()=>status='Request sent for ${o.title}. Membership and access should be approved by the backend.');},icon:const Icon(Icons.group_add_outlined),label:const Text('Request to join'))
  )])));
}
