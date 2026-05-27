class AppUser {
  final String id;
  final String name;
  final String role;
  final DateTime loginTime;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.loginTime,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? '${name[0]}${name[1]}'.toUpperCase()
        : name[0].toUpperCase();
  }
}
