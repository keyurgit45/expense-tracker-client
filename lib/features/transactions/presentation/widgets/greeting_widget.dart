import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    // Time-based greetings
    if (hour < 5) {
      return _getRandomGreeting([
        'Burning the midnight oil, Keyur?',
        'Night owl mode activated',
        'The stars are out, Keyur',
        'Late night financial planning?',
      ]);
    } else if (hour < 12) {
      return _getRandomGreeting([
        'Good morning, Keyur',
        'Rise and shine, Keyur',
        'Fresh start today, Keyur',
        'Morning momentum',
        'Early bird gets the deals',
      ]);
    } else if (hour < 17) {
      return _getRandomGreeting([
        'Good afternoon, Keyur',
        'Midday check-in',
        'Afternoon insights await',
        'Peak productivity hours',
      ]);
    } else if (hour < 21) {
      return _getRandomGreeting([
        'Good evening, Keyur',
        'Evening reflections',
        'Winding down, Keyur?',
        'Golden hour greetings',
      ]);
    } else {
      return _getRandomGreeting([
        'Night time, Keyur',
        'Evening insights',
        'Peaceful evening ahead',
        'Time to review the day',
      ]);
    }
  }

  String _getSubtext() {
    final day = DateTime.now().day;
    final weekday = DateTime.now().weekday;
    final hour = DateTime.now().hour;
    
    // Context-aware subtexts
    if (day == 1) {
      return 'Fresh month, fresh opportunities';
    } else if (day >= 25) {
      return 'Month-end approaching';
    } else if (weekday == 1) {
      return 'New week, new goals';
    } else if (weekday == 5) {
      return 'TGIF vibes';
    } else if (hour < 12) {
      return 'Let\'s make today count';
    } else if (hour >= 17) {
      return 'How was your spending today?';
    } else {
      return _getRandomGreeting([
        'Your finances at a glance',
        'Track, analyze, optimize',
        'Every rupee counts',
        'Building wealth, one transaction at a time',
        'Your financial command center',
        'Smart spending starts here',
        'Knowledge is financial power',
      ]);
    }
  }

  String _getRandomGreeting(List<String> options) {
    // Use day of year as seed for consistent daily greeting
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return options[dayOfYear % options.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: GoogleFonts.inter(
            color: ColorConstants.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getSubtext(),
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}