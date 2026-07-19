class Expense {
  final String? id;
  final String userId;
  final String? categoryId;
  final String title;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? createAt;

  Expense({
    this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    required this.amount,
    this.description,
    required this.date,
    this.createAt,
  });
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      title: json['title'],
      amount: (json['amount'] is String)
          ? double.parse(json['amount'])
          : (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      createAt: json['createAt'] != null
          ? DateTime.parse(json['createAt'] as String)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'title': title,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      if (createAt != null) 'createAt': createAt!.toIso8601String(),
    };
  }

  // create a copy with updated fields
  Expense copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createAt: createAt ?? this.createAt,
    );
  }
  //   @override
  // String toString() {
  //   return 'Expense(id: $id,  title: $title, amount: $amount, description: $description, date: $date, createAt: $createAt)';
  // }

  @override
  String toString() {
    return 'Expense( id:$id, title:$title, amount:$amount,  date:$date, )';
  }
}
