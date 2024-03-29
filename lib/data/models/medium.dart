class Medium {
  Medium({
    required this.name,
    required this.id,
  });
  late final String name;
  late final int id;

  Medium.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    id = int.parse((json['id'] ?? -1).toString());
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
