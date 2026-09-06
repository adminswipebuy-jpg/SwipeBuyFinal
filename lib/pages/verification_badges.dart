import 'package:flutter/material.dart';

class VerificationBadges extends StatelessWidget {
  final bool identityVerified;
  final bool businessVerified;
  final bool trustedProvider;

  const VerificationBadges({
    super.key,
    this.identityVerified = false,
    this.businessVerified = false,
    this.trustedProvider = false,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (identityVerified) badges.add(_badge(Icons.badge_outlined, 'Identity'));
    if (businessVerified) badges.add(_badge(Icons.business_outlined, 'Business'));
    if (trustedProvider) badges.add(_badge(Icons.verified, 'Trusted'));

    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 6, children: badges);
  }

  Widget _badge(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
