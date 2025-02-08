class Instance {
  final int id;
  final String name;
  final String folderName;

  Instance({
    required this.id,
    required this.name,
    required this.folderName,
  });

  // You can add factory methods to create Instances from JSON or database data
  factory Instance.fromJson(Map<String, dynamic> json) {
    return Instance(
      id: json['id'],
      name: json['name'],
      folderName: json['folderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'folderName': folderName,
    };
  }
}