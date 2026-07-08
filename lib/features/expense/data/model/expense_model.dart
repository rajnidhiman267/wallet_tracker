import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  bills,
  education,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.shopping: return 'Shopping';
      case ExpenseCategory.health: return 'Health';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.bills: return 'Bills';
      case ExpenseCategory.education: return 'Education';
      case ExpenseCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚗';
      case ExpenseCategory.shopping: return '🛍️';
      case ExpenseCategory.health: return '💊';
      case ExpenseCategory.entertainment: return '🎬';
      case ExpenseCategory.bills: return '💡';
      case ExpenseCategory.education: return '📚';
      case ExpenseCategory.other: return '📦';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class ExpenseModel {
  final String? id;
  final String uid;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const ExpenseModel({
    this.id,
    required this.uid,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  ExpenseModel copyWith({
    String? id,
    String? uid,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String docId) {
    return ExpenseModel(
      id: docId,
      uid: json['uid'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategoryExtension.fromString(json['category'] ?? ''),
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: json['note'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}