import 'package:flutter/material.dart';

class ListingDetails extends StatelessWidget {
  final dynamic listing;
  const ListingDetails({super.key, this.listing});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Details')), body: const Center(child: Text('Details Page')));
}

class ProfessionalProfile extends StatelessWidget {
  final dynamic person;
  const ProfessionalProfile({super.key, this.person});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: Text('Profile Page')));
}

class CategoryHubPage extends StatelessWidget {
  final dynamic category;
  const CategoryHubPage({super.key, this.category});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('$category')), body: Center(child: Text('$category')));
}