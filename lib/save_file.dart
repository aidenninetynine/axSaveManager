class SaveFile {
  final int id;
  final String name;
  final String folderName;
  final int instanceId; // Foreign key to Instance

  SaveFile({
    required this.id,
    required this.name,
    required this.folderName,
    required this.instanceId,
  });

  // Factory method to create SaveFiles from JSON or database data
  factory SaveFile.fromJson(Map<String, dynamic> json) {
    return SaveFile(
      id: json['id'],
      name: json['name'],
      folderName: json['folderName'],
      instanceId: json['instanceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'folderName': folderName,
      'instanceId': instanceId,
    };
  }
}