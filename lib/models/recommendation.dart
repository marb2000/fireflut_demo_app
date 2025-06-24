import 'package:flutter/material.dart';

class Recommendation {
  final String service;
  final String title;
  final String description;
  final IconData icon;

  const Recommendation({
    required this.service,
    required this.title,
    required this.description,
    required this.icon,
  });
}
