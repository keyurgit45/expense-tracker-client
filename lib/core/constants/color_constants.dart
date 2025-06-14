import 'package:flutter/material.dart';

class ColorConstants {
  // Prevent instantiation
  ColorConstants._();

  // Background colors
  static const Color bgPrimary = Color(0xFF0A0A0A); // Near black background
  static const Color bgSecondary = Color(0xFF141414); // Slightly lighter for cards
  static const Color bgTertiary = Color(0xFF1F1F1F); // For elevated surfaces
  static const Color bgQuaternary = Color(0xFF2A2A2A); // For hover states

  // Text colors
  static const Color textPrimary = Color(0xFFE5E5E5); // High emphasis text
  static const Color textSecondary = Color(0xFF999999); // Medium emphasis text
  static const Color textTertiary = Color(0xFF666666); // Low emphasis text
  static const Color textQuaternary = Color(0xFF4D4D4D); // Very low emphasis

  // Border colors
  static const Color borderSubtle = Color(0xFF1F1F1F); // Barely visible
  static const Color borderDefault = Color(0xFF2A2A2A); // Default borders
  static const Color borderStrong = Color(0xFF3A3A3A); // Emphasized borders

  // Interactive elements
  static const Color interactive = Color(0xFFE5E5E5); // Buttons, links
  static const Color interactiveHover = Color(0xFFFFFFFF); // Hover state
  static const Color interactivePressed = Color(0xFFCCCCCC); // Pressed state
  static const Color interactiveDisabled = Color(0xFF4D4D4D); // Disabled state

  // Surface colors (for cards, modals, etc.)
  static const Color surface1 = Color(0xFF141414); // Lowest elevation
  static const Color surface2 = Color(0xFF1F1F1F); // Medium elevation
  static const Color surface3 = Color(0xFF2A2A2A); // High elevation

  // Semantic colors (monochrome)
  static const Color positive = Color(0xFFE5E5E5); // Income/positive values
  static const Color negative = Color(0xFF666666); // Expense/negative values
  static const Color positiveSubtle = Color(0xFF2A2A2A); // Positive background
  static const Color negativeSubtle = Color(0xFF1A1A1A); // Negative background

  // Shadows
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  // Gradients
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF1F1F1F),
      Color(0xFF2A2A2A),
      Color(0xFF1F1F1F),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF141414),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}