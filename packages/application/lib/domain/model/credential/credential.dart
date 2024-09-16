class Credential {
  final String id;
  final String password;
  final List<dynamic> cookies;

  const Credential({
    required this.id,
    required this.password,
    required this.cookies,
  });

  factory Credential.empty() => Credential(id: "", password: "", cookies: []);
}
