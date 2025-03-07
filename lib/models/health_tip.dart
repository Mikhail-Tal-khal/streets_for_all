import 'package:flutter/material.dart';

class HealthTip {
  final String id;
  final String title;
  final String description;
  final String fullContent;
  final IconData icon;
  final String category;
  final List<String> tags;
  final DateTime publishedDate;

  const HealthTip({
    required this.id,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.icon,
    required this.category,
    this.tags = const [],
    required this.publishedDate,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fullContent: json['fullContent'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      publishedDate: DateTime.parse(json['publishedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fullContent': fullContent,
      'iconCodePoint': icon.codePoint,
      'category': category,
      'tags': tags,
      'publishedDate': publishedDate.toIso8601String(),
    };
  }
}
