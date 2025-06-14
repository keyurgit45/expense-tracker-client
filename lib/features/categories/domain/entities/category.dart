import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final String? parentCategoryId;

  const Category({
    required this.id,
    required this.name,
    this.isActive = true,
    this.parentCategoryId,
  });

  // Helper method to get icon based on name
  String get icon {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('shopping')) return '🛍️';
    if (lowerName.contains('food') || lowerName.contains('restaurant')) return '🍽️';
    if (lowerName.contains('transport')) return '🚗';
    if (lowerName.contains('entertainment')) return '🎬';
    if (lowerName.contains('health')) return '🏥';
    if (lowerName.contains('education')) return '📚';
    return '📁';
  }

  // Helper method to get color based on name
  String get color {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('shopping')) return '#E8F5E8';
    if (lowerName.contains('food') || lowerName.contains('restaurant')) return '#F0E8FF';
    if (lowerName.contains('transport')) return '#E8F0FF';
    if (lowerName.contains('entertainment')) return '#FFE8E8';
    if (lowerName.contains('health')) return '#FFE8F0';
    if (lowerName.contains('education')) return '#FFF0E8';
    return '#F0F0F0';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        isActive,
        parentCategoryId,
      ];
}