import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart'; // Generated adapter file

final formatter = DateFormat('dd/MM/yyyy');
const uuid = Uuid();

@HiveType(typeId: 0) // Provide a unique typeId for each class
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  travel,
  @HiveField(2)
  leisure,
  @HiveField(3)
  work,
  @HiveField(4)
  other,
}

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.surfing,
  Category.work: Icons.work,
  Category.other: Icons.emoji_objects,
};

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final Category category;

  String get formattedDate => formatter.format(date);

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();
}
