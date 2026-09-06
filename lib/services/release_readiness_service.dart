class ReleaseCheck {
  const ReleaseCheck({required this.area, required this.description, required this.status});
  final String area;
  final String description;
  final ReleaseStatus status;
}

enum ReleaseStatus { ready, review, blocked }

class ReleaseReadinessService {
  static const checks = <ReleaseCheck>[
    ReleaseCheck(area: 'Authentication', description: 'Firebase auth and auth gate are wired into the app shell.', status: ReleaseStatus.review),
    ReleaseCheck(area: 'Navigation', description: 'Major feature areas are reachable from the main shell/profile surfaces.', status: ReleaseStatus.review),
    ReleaseCheck(area: 'Backend boundaries', description: 'Sensitive actions remain intended for trusted backend services.', status: ReleaseStatus.review),
    ReleaseCheck(area: 'Payments', description: 'Production provider credentials, webhooks and reconciliation still require real configuration.', status: ReleaseStatus.blocked),
    ReleaseCheck(area: 'Security', description: 'Production rules, secrets review and abuse testing require release verification.', status: ReleaseStatus.review),
    ReleaseCheck(area: 'Testing', description: 'End-to-end device testing and automated regression coverage are required before V15.', status: ReleaseStatus.blocked),
  ];

  static int get readyCount => checks.where((c) => c.status == ReleaseStatus.ready).length;
  static int get reviewCount => checks.where((c) => c.status == ReleaseStatus.review).length;
  static int get blockedCount => checks.where((c) => c.status == ReleaseStatus.blocked).length;
}
