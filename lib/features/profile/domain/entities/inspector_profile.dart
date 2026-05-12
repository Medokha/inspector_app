class InspectorProfile {
  const InspectorProfile({
    required this.name,
    required this.email,
    required this.region,
    required this.initials,
    required this.tags,
  });

  final String name;
  final String email;
  final String region;
  final String initials;
  final List<String> tags;
}
