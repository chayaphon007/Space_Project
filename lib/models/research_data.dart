class ResearchData {
  final int? id;
  final String category;
  final String title;
  final String description;
  final String inventor;
  final String? imagePath; // ✅ รองรับรูปภาพ
  final String date;
  ResearchData({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.inventor,
    this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'inventor': inventor,
      'imagePath': imagePath,
      'date': date,
    };
  }

  factory ResearchData.fromMap(Map<String, dynamic> map) {
    return ResearchData(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      description: map['description'],
      inventor: map['inventor'],
      imagePath: map['imagePath'] ?? "",
      date: map['date'] ?? "", // ✅ ป้องกัน null error
    );
  }
}
