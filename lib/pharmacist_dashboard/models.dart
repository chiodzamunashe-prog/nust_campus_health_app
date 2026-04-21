class Medication {
  final String id;
  final String name;
  final String category;
  final int stock;
  final String unit; // e.g., tablets, ml, vials

  Medication({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    this.unit = 'tablets',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'stock': stock,
      'unit': unit,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, String id) {
    return Medication(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      unit: map['unit'] ?? 'tablets',
    );
  }
}
