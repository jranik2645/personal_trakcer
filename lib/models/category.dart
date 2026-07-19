class Category {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final DateTime? createAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.createAt,
  });

  // create category from json
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      createAt: json['createAt'] != null
          ? DateTime.parse(json['createAt'] as String)
          : null,
    );
  }
  // convert category to json
  Map<String, dynamic> toJson() {
    return {
      if (icon != null) 'icon': icon,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'createAt': createAt?.toIso8601String(),
    };
  }

  // create a copy with updated fields
  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    DateTime? createAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createAt: createAt ?? this.createAt,
    );
  }

  //  @override
  //   String toString() {
  //     return 'Category{id: $id, userId: $userId, name: $name, description: $description, icon: $icon, color: $color, createAt: $createAt}';
  //   }

  @override
  String toString() {
    return 'Category(id: $id,  name: $name,  color: $color, )';
  }
}
