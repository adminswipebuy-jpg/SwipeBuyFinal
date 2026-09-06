import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/social_service.dart';

class SocialActions extends StatelessWidget {
  final String listingId, providerId;
  final SocialService service;
  const SocialActions({super.key, required this.listingId, required this.providerId, required this.service});
  @override Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    StreamBuilder<bool>(stream: service.isLiked(listingId), builder: (_, s) { final on=s.data??false; return IconButton(onPressed: ()=>on?service.unlikeListing(listingId):service.likeListing(listingId), icon: Icon(on?Icons.favorite:Icons.favorite_border)); }),
    StreamBuilder<bool>(stream: service.isSaved(listingId), builder: (_, s) { final on=s.data??false; return IconButton(onPressed: ()=>on?service.unsaveListing(listingId):service.saveListing(listingId), icon: Icon(on?Icons.bookmark:Icons.bookmark_border)); }),
    IconButton(onPressed: ()=>showModalBottomSheet(context: context,isScrollControlled:true,builder:(_)=>CommentsSheet(listingId:listingId,service:service)),icon:const Icon(Icons.chat_bubble_outline)),
    IconButton(onPressed: ()=>service.recordShare(listingId),icon:const Icon(Icons.share_outlined)),
  ]);
}

class FollowButton extends StatelessWidget {
  final String providerId; final SocialService service;
  const FollowButton({super.key,required this.providerId,required this.service});
  @override Widget build(BuildContext context)=>StreamBuilder<bool>(stream:service.isFollowing(providerId),builder:(_,s){final on=s.data??false;return OutlinedButton.icon(onPressed:()=>on?service.unfollowProvider(providerId):service.followProvider(providerId),icon:Icon(on?Icons.check:Icons.person_add_alt_1),label:Text(on?'Following':'Follow'));});
}

class CommentsSheet extends StatefulWidget { final String listingId; final SocialService service; const CommentsSheet({super.key,required this.listingId,required this.service}); @override State<CommentsSheet> createState()=>_CommentsSheetState(); }
class _CommentsSheetState extends State<CommentsSheet>{final c=TextEditingController(); @override void dispose(){c.dispose();super.dispose();} Future<void> send()async{await widget.service.addComment(widget.listingId,c.text);c.clear();} @override Widget build(BuildContext context)=>SafeArea(child:SizedBox(height:MediaQuery.of(context).size.height*.7,child:Column(children:[const Padding(padding:EdgeInsets.all(16),child:Text('Comments',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),Expanded(child:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:widget.service.comments(widget.listingId),builder:(_,s){if(s.hasError)return const Center(child:Text('Unable to load comments.'));if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;if(d.isEmpty)return const Center(child:Text('Be the first to comment.'));return ListView.builder(itemCount:d.length,itemBuilder:(_,i){final x=d[i].data();return ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(x['userId']?.toString()??'User'),subtitle:Text(x['text']?.toString()??''));});})),Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:TextField(controller:c,decoration:const InputDecoration(hintText:'Add a comment...'))),IconButton(onPressed:send,icon:const Icon(Icons.send))]))])));}
